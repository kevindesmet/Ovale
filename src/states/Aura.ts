import { L } from "../ui/Localization";
import { OvaleDebugClass, Tracer } from "../engine/debug";
import { OvalePool } from "../tools/Pool";
import { OvaleProfilerClass, Profiler } from "../engine/profiler";
import {
    OvaleDataClass,
    SpellAddAurasByType,
    AuraType,
    SpellInfo,
} from "../engine/data";
import { OvaleGUIDClass } from "../engine/guid";
import { OvaleSpellBookClass } from "./SpellBook";
import { OvaleStateClass, StateModule, States } from "../engine/state";
import { OvaleClass } from "../Ovale";
import { LastSpell, SpellCast, PaperDollSnapshot } from "./LastSpell";
import aceEvent, { AceEvent } from "@wowts/ace_event-3.0";
import {
    pairs,
    tonumber,
    wipe,
    lualength,
    LuaObj,
    next,
    LuaArray,
    kpairs,
    unpack,
} from "@wowts/lua";
import { lower } from "@wowts/string";
import { concat, insert, sort } from "@wowts/table";
import {
    GetTime,
    UnitAura,
    CombatLogGetCurrentEventInfo,
} from "@wowts/wow-mock";
import { huge as INFINITY, huge } from "@wowts/math";
import { OvalePaperDollClass } from "./PaperDoll";
import { BaseState } from "./BaseState";
import { isNumber, isString } from "../tools/tools";
import {
    ConditionFunction,
    ConditionResult,
    OvaleConditionClass,
    ParseCondition,
    ReturnConstant,
    ReturnValue,
} from "../engine/condition";
import { OvaleOptionsClass } from "../ui/Options";
import { AceModule } from "@wowts/tsaddon";
import { OptionUiAll } from "../ui/acegui-helpers";

const strlower = lower;
const tconcat = concat;

let self_playerGUID = "fake_guid";
let self_petGUID: LuaObj<number> = {};
const self_pool = new OvalePool<Aura | LuaObj<Aura> | LuaObj<LuaObj<Aura>>>(
    "OvaleAura_pool"
);

type UnitAuraFilter =
    | "HARMFUL"
    | "HELPFUL"
    | "HARMFUL|PLAYER"
    | "HELPFUL|PLAYER";

const UNKNOWN_GUID = "0";

export const DEBUFF_TYPE: LuaObj<boolean> = {
    curse: true,
    disease: true,
    enrage: true,
    magic: true,
    poison: true,
};
export const SPELLINFO_DEBUFF_TYPE: LuaObj<string> = {};

{
    for (const [debuffType] of pairs(DEBUFF_TYPE)) {
        const siDebuffType = strlower(debuffType);
        SPELLINFO_DEBUFF_TYPE[siDebuffType] = debuffType;
    }
}
const CLEU_AURA_EVENTS: LuaObj<boolean> = {
    SPELL_AURA_APPLIED: true,
    SPELL_AURA_REMOVED: true,
    SPELL_AURA_APPLIED_DOSE: true,
    SPELL_AURA_REMOVED_DOSE: true,
    SPELL_AURA_REFRESH: true,
    SPELL_AURA_BROKEN: true,
    SPELL_AURA_BROKEN_SPELL: true,
};
const CLEU_TICK_EVENTS: LuaObj<boolean> = {
    SPELL_PERIODIC_DAMAGE: true,
    SPELL_PERIODIC_HEAL: true,
    SPELL_PERIODIC_ENERGIZE: true,
    SPELL_PERIODIC_DRAIN: true,
    SPELL_PERIODIC_LEECH: true,
};

const array = {};

//let CLEU_SCHOOL_MASK_MAGIC = bit_bor(_SCHOOL_MASK_ARCANE, _SCHOOL_MASK_FIRE, _SCHOOL_MASK_FROST, _SCHOOL_MASK_HOLY, _SCHOOL_MASK_NATURE, _SCHOOL_MASK_SHADOW);

export interface Aura extends SpellCast {
    serial: number;
    stacks: number;
    start: number;
    ending: number;
    debuffType: number | string | undefined;
    filter: AuraType;
    state: boolean;
    name: string;
    gain: number;
    spellId: number;
    visible: boolean;
    lastUpdated: number;
    duration: number;
    baseTick: number | undefined;
    tick: number | undefined;
    guid: string;
    source: string;
    lastTickTime: number | undefined;
    value1: number | undefined;
    value2: number | undefined;
    value3: number | undefined;
    direction: number;
    consumed: boolean;
    icon: string | undefined;
    stealable: boolean;
    snapshotTime: number;
    cooldownEnding: number;
    combopoints?: number;
    damageMultiplier?: number;
}

type AuraDB = LuaObj<LuaObj<LuaObj<Aura>>>;

/** Either a spell id or a spell list name */
type AuraId = number | string;

export function PutAura(
    auraDB: AuraDB,
    guid: string,
    auraId: AuraId,
    casterGUID: string,
    aura: Aura
) {
    let auraForGuid = auraDB[guid];
    if (!auraForGuid) {
        auraForGuid = <LuaObj<LuaObj<Aura>>>self_pool.Get();
        auraDB[guid] = auraForGuid;
    }
    let auraForId = auraForGuid[auraId];
    if (!auraForId) {
        auraForId = <LuaObj<Aura>>self_pool.Get();
        auraForGuid[auraId] = auraForId;
    }
    const previousAura = auraForId[casterGUID];
    if (previousAura) {
        self_pool.Release(previousAura);
    }
    auraForId[casterGUID] = aura;
    aura.guid = guid;
    aura.spellId = <number>auraId; // TODO
    aura.source = casterGUID;
}
export function GetAura(
    auraDB: AuraDB,
    guid: string,
    auraId: AuraId,
    casterGUID: string
) {
    if (
        auraDB[guid] &&
        auraDB[guid][auraId] &&
        auraDB[guid][auraId][casterGUID]
    ) {
        return auraDB[guid][auraId][casterGUID];
    }
}

function GetAuraAnyCaster(auraDB: AuraDB, guid: string, auraId: AuraId) {
    let auraFound;
    if (auraDB[guid] && auraDB[guid][auraId]) {
        for (const [, aura] of pairs(auraDB[guid][auraId])) {
            if (!auraFound || auraFound.ending < aura.ending) {
                auraFound = aura;
            }
        }
    }
    return auraFound;
}

function GetDebuffType(
    auraDB: AuraDB,
    guid: string,
    debuffType: AuraId,
    filter: string,
    casterGUID: string
) {
    let auraFound;
    if (auraDB[guid]) {
        for (const [, whoseTable] of pairs(auraDB[guid])) {
            const aura = whoseTable[casterGUID];
            if (
                aura &&
                aura.debuffType == debuffType &&
                aura.filter == filter
            ) {
                if (!auraFound || auraFound.ending < aura.ending) {
                    auraFound = aura;
                }
            }
        }
    }
    return auraFound;
}

function GetDebuffTypeAnyCaster(
    auraDB: AuraDB,
    guid: string,
    debuffType: AuraId,
    filter: string
) {
    let auraFound;
    if (auraDB[guid]) {
        for (const [, whoseTable] of pairs(auraDB[guid])) {
            for (const [, aura] of pairs(whoseTable)) {
                if (
                    aura &&
                    aura.debuffType == debuffType &&
                    aura.filter == filter
                ) {
                    if (!auraFound || auraFound.ending < aura.ending) {
                        auraFound = aura;
                    }
                }
            }
        }
    }
    return auraFound;
}
function GetAuraOnGUID(
    auraDB: AuraDB,
    guid: string,
    auraId: AuraId,
    filter: string,
    mine: boolean
) {
    let auraFound: Aura | undefined;
    if (DEBUFF_TYPE[auraId]) {
        if (mine && self_playerGUID) {
            auraFound = GetDebuffType(
                auraDB,
                guid,
                auraId,
                filter,
                self_playerGUID
            );
            if (!auraFound) {
                for (const [petGUID] of pairs(self_petGUID)) {
                    const aura = GetDebuffType(
                        auraDB,
                        guid,
                        auraId,
                        filter,
                        petGUID
                    );
                    if (
                        aura &&
                        (!auraFound || auraFound.ending < aura.ending)
                    ) {
                        auraFound = aura;
                    }
                }
            }
        } else {
            auraFound = GetDebuffTypeAnyCaster(auraDB, guid, auraId, filter);
        }
    } else {
        if (mine && self_playerGUID) {
            auraFound = GetAura(auraDB, guid, auraId, self_playerGUID);
            if (!auraFound) {
                for (const [petGUID] of pairs(self_petGUID)) {
                    const aura = GetAura(auraDB, guid, auraId, petGUID);
                    if (
                        aura &&
                        (!auraFound || auraFound.ending < aura.ending)
                    ) {
                        auraFound = aura;
                    }
                }
            }
        } else {
            auraFound = GetAuraAnyCaster(auraDB, guid, auraId);
        }
    }
    return auraFound;
}

export function RemoveAurasOnGUID(auraDB: AuraDB, guid: string) {
    if (auraDB[guid]) {
        const auraTable = auraDB[guid];
        for (const [auraId, whoseTable] of pairs(auraTable)) {
            for (const [casterGUID, aura] of pairs(whoseTable)) {
                self_pool.Release(aura);
                delete whoseTable[casterGUID];
            }
            self_pool.Release(whoseTable);
            delete auraTable[auraId];
        }
        self_pool.Release(auraTable);
        delete auraDB[guid];
    }
}

class AuraInterface {
    aura: AuraDB = {};
    serial: LuaObj<number> = {};
    auraSerial = 0;
}

let count: number;
let stacks: number;
let startChangeCount, endingChangeCount: number;
let startFirst: number, endingLast: number;

export class OvaleAuraClass
    extends States<AuraInterface>
    implements StateModule {
    private debug: Tracer;
    private module: AceModule & AceEvent;
    private profiler: Profiler;

    constructor(
        private ovaleState: OvaleStateClass,
        private ovalePaperDoll: OvalePaperDollClass,
        private baseState: BaseState,
        private ovaleData: OvaleDataClass,
        private ovaleGuid: OvaleGUIDClass,
        private lastSpell: LastSpell,
        private ovaleOptions: OvaleOptionsClass,
        private ovaleDebug: OvaleDebugClass,
        private ovale: OvaleClass,
        ovaleProfiler: OvaleProfilerClass,
        private ovaleSpellBook: OvaleSpellBookClass
    ) {
        super(AuraInterface);
        this.module = ovale.createModule(
            "OvaleAura",
            this.OnInitialize,
            this.OnDisable,
            aceEvent
        );
        this.debug = ovaleDebug.create("OvaleAura");
        this.profiler = ovaleProfiler.create("OvaleAura");
        this.ovaleState.RegisterState(this);
        this.addDebugOptions();
    }

    registerConditions(condition: OvaleConditionClass) {
        condition.RegisterCondition(
            "bufflastexpire",
            true,
            this.buffLastExpire
        );
        condition.RegisterCondition(
            "ticksgainedonrefresh",
            true,
            this.ticksGainedOnRefresh
        );
    }

    IsWithinAuraLag(time1: number, time2: number, factor?: number) {
        factor = factor || 1;
        const auraLag = this.ovaleOptions.db.profile.apparence.auraLag;
        const tolerance = (factor * auraLag) / 1000;
        return time1 - time2 < tolerance && time2 - time1 < tolerance;
    }

    private CountMatchingActiveAura(aura: Aura) {
        this.debug.Log(
            "Counting aura %s found on %s with (%s, %s)",
            aura.spellId,
            aura.guid,
            aura.start,
            aura.ending
        );
        count = count + 1;
        stacks = stacks + aura.stacks;
        if (aura.ending < endingChangeCount) {
            [startChangeCount, endingChangeCount] = [aura.gain, aura.ending];
        }
        if (aura.gain < startFirst) {
            startFirst = aura.gain;
        }
        if (aura.ending > endingLast) {
            endingLast = aura.ending;
        }
    }

    private addDebugOptions() {
        const output: LuaArray<string> = {};
        const debugOptions: LuaObj<OptionUiAll> = {
            playerAura: {
                name: L["auras_player"],
                type: "group",
                args: {
                    buff: {
                        name: L["auras_on_player"],
                        type: "input",
                        multiline: 25,
                        width: "full",
                        get: (info: LuaArray<string>) => {
                            wipe(output);
                            const now = GetTime();
                            const helpful = this.DebugUnitAuras(
                                "player",
                                "HELPFUL",
                                now
                            );
                            if (helpful) {
                                output[lualength(output) + 1] = "== BUFFS ==";
                                output[lualength(output) + 1] = helpful;
                            }
                            const harmful = this.DebugUnitAuras(
                                "player",
                                "HARMFUL",
                                now
                            );
                            if (harmful) {
                                output[lualength(output) + 1] = "== DEBUFFS ==";
                                output[lualength(output) + 1] = harmful;
                            }
                            return tconcat(output, "\n");
                        },
                    },
                },
            },
            targetAura: {
                name: L["auras_target"],
                type: "group",
                args: {
                    targetbuff: {
                        name: L["auras_on_target"],
                        type: "input",
                        multiline: 25,
                        width: "full",
                        get: (info: LuaArray<string>) => {
                            wipe(output);
                            const now = GetTime();
                            const helpful = this.DebugUnitAuras(
                                "target",
                                "HELPFUL",
                                now
                            );
                            if (helpful) {
                                output[lualength(output) + 1] = "== BUFFS ==";
                                output[lualength(output) + 1] = helpful;
                            }
                            const harmful = this.DebugUnitAuras(
                                "target",
                                "HARMFUL",
                                now
                            );
                            if (harmful) {
                                output[lualength(output) + 1] = "== DEBUFFS ==";
                                output[lualength(output) + 1] = harmful;
                            }
                            return tconcat(output, "\n");
                        },
                    },
                },
            },
        };
        for (const [k, v] of pairs(debugOptions)) {
            this.ovaleDebug.defaultOptions.args[k] = v;
        }
    }

    private OnInitialize = () => {
        self_playerGUID = this.ovale.playerGUID;
        self_petGUID = this.ovaleGuid.petGUID;
        this.module.RegisterEvent(
            "COMBAT_LOG_EVENT_UNFILTERED",
            this.COMBAT_LOG_EVENT_UNFILTERED
        );
        this.module.RegisterEvent(
            "PLAYER_ENTERING_WORLD",
            this.PLAYER_ENTERING_WORLD
        );
        this.module.RegisterEvent(
            "PLAYER_REGEN_ENABLED",
            this.PLAYER_REGEN_ENABLED
        );
        this.module.RegisterEvent("UNIT_AURA", this.UNIT_AURA);
        this.module.RegisterMessage(
            "Ovale_GroupChanged",
            this.handleOvaleGroupChanged
        );
        this.module.RegisterMessage(
            "Ovale_UnitChanged",
            this.Ovale_UnitChanged
        );
    };

    private OnDisable = () => {
        this.module.UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        this.module.UnregisterEvent("PLAYER_ENTERING_WORLD");
        this.module.UnregisterEvent("PLAYER_REGEN_ENABLED");
        this.module.UnregisterEvent("PLAYER_UNGHOST");
        this.module.UnregisterEvent("UNIT_AURA");
        this.module.UnregisterMessage("Ovale_GroupChanged");
        this.module.UnregisterMessage("Ovale_UnitChanged");
        for (const [guid] of pairs(this.current.aura)) {
            RemoveAurasOnGUID(this.current.aura, guid);
        }
        self_pool.Drain();
    };

    private COMBAT_LOG_EVENT_UNFILTERED = (event: string, ...__args: any[]) => {
        this.debug.DebugTimestamp(
            "COMBAT_LOG_EVENT_UNFILTERED",
            CombatLogGetCurrentEventInfo()
        );
        const [
            ,
            cleuEvent,
            ,
            sourceGUID,
            ,
            ,
            ,
            destGUID,
            ,
            ,
            ,
            spellId,
            spellName,
            ,
            auraType,
            amount,
        ] = CombatLogGetCurrentEventInfo();
        const mine =
            sourceGUID == self_playerGUID ||
            this.ovaleGuid.IsPlayerPet(sourceGUID);
        if (mine && cleuEvent == "SPELL_MISSED") {
            const [unitId] = this.ovaleGuid.GUIDUnit(destGUID);
            if (unitId) {
                this.debug.DebugTimestamp(
                    "%s: %s (%s)",
                    cleuEvent,
                    destGUID,
                    unitId
                );
                this.ScanAuras(unitId, destGUID);
            }
        }
        if (CLEU_AURA_EVENTS[cleuEvent]) {
            this.ovaleData.registerAuraSeen(spellId);
            const [unitId] = this.ovaleGuid.GUIDUnit(destGUID);
            this.debug.DebugTimestamp("UnitId: ", unitId);
            if (unitId) {
                if (!this.ovaleGuid.UNIT_AURA_UNIT[unitId]) {
                    this.debug.DebugTimestamp(
                        "%s: %s (%s)",
                        cleuEvent,
                        destGUID,
                        unitId
                    );
                    this.ScanAuras(unitId, destGUID);
                }
            } else if (mine) {
                this.debug.DebugTimestamp(
                    "%s: %s (%d) on %s",
                    cleuEvent,
                    spellName,
                    spellId,
                    destGUID
                );
                const now = GetTime();
                if (
                    cleuEvent == "SPELL_AURA_REMOVED" ||
                    cleuEvent == "SPELL_AURA_BROKEN" ||
                    cleuEvent == "SPELL_AURA_BROKEN_SPELL"
                ) {
                    this.LostAuraOnGUID(destGUID, now, spellId, sourceGUID);
                } else {
                    const filter: AuraType =
                        (auraType == "BUFF" && "HELPFUL") || "HARMFUL";
                    const si = this.ovaleData.spellInfo[spellId];
                    const aura = GetAuraOnGUID(
                        this.current.aura,
                        destGUID,
                        spellId,
                        filter,
                        true
                    );
                    let duration = 15;
                    if (aura) {
                        duration = aura.duration;
                    } else if (si && si.duration) {
                        [duration] = this.ovaleData.GetSpellInfoPropertyNumber(
                            spellId,
                            now,
                            "duration",
                            destGUID
                        ) || [15];
                    }
                    const expirationTime = now + duration;
                    let count;
                    if (cleuEvent == "SPELL_AURA_APPLIED") {
                        count = 1;
                    } else if (
                        cleuEvent == "SPELL_AURA_APPLIED_DOSE" ||
                        cleuEvent == "SPELL_AURA_REMOVED_DOSE"
                    ) {
                        count = amount;
                    } else if (cleuEvent == "SPELL_AURA_REFRESH") {
                        count = (aura && aura.stacks) || 1;
                    }
                    this.GainedAuraOnGUID(
                        destGUID,
                        now,
                        spellId,
                        sourceGUID,
                        filter,
                        true,
                        undefined,
                        count,
                        undefined,
                        duration,
                        expirationTime,
                        false,
                        spellName
                    );
                }
            }
        } else if (mine && CLEU_TICK_EVENTS[cleuEvent] && self_playerGUID) {
            this.ovaleData.registerAuraSeen(spellId);
            this.debug.DebugTimestamp("%s: %s", cleuEvent, destGUID);
            const aura = GetAura(
                this.current.aura,
                destGUID,
                spellId,
                self_playerGUID
            );
            const now = GetTime();
            if (aura && this.IsActiveAura(aura, now)) {
                const name = aura.name || "Unknown spell";
                let [baseTick, lastTickTime] = [
                    aura.baseTick,
                    aura.lastTickTime,
                ];
                let tick;
                if (lastTickTime) {
                    tick = now - lastTickTime;
                } else if (!baseTick) {
                    this.debug.Debug(
                        "    First tick seen of unknown periodic aura %s (%d) on %s.",
                        name,
                        spellId,
                        destGUID
                    );
                    const si = this.ovaleData.spellInfo[spellId];
                    baseTick = (si && si.tick && si.tick) || 3;
                    tick = this.GetTickLength(spellId);
                } else {
                    tick = baseTick;
                }
                aura.baseTick = baseTick;
                aura.lastTickTime = now;
                aura.tick = tick;
                this.debug.Debug(
                    "    Updating %s (%s) on %s, tick=%s, lastTickTime=%s",
                    name,
                    spellId,
                    destGUID,
                    tick,
                    lastTickTime
                );
                this.ovale.refreshNeeded[destGUID] = true;
            }
        }
    };

    private PLAYER_ENTERING_WORLD = (event: string) => {
        this.ScanAllUnitAuras();
    };

    private PLAYER_REGEN_ENABLED = (event: string) => {
        this.RemoveAurasOnInactiveUnits();
        self_pool.Drain();
    };

    private UNIT_AURA = (event: string, unitId: string) => {
        this.debug.Debug(event, unitId);
        this.ScanAuras(unitId);
    };

    private handleOvaleGroupChanged = () => this.ScanAllUnitAuras();

    private Ovale_UnitChanged = (
        event: string,
        unitId: string,
        guid: string
    ) => {
        if ((unitId == "pet" || unitId == "target") && guid) {
            this.debug.Debug(event, unitId, guid);
            this.ScanAuras(unitId, guid);
        }
    };

    private ScanAllUnitAuras() {
        for (const [unitId] of pairs(this.ovaleGuid.UNIT_AURA_UNIT)) {
            this.ScanAuras(unitId);
        }
    }

    private RemoveAurasOnInactiveUnits() {
        for (const [guid] of pairs(this.current.aura)) {
            const unitId = this.ovaleGuid.GUIDUnit(guid);
            if (!unitId) {
                this.debug.Debug("Removing auras from GUID %s", guid);
                RemoveAurasOnGUID(this.current.aura, guid);
                delete this.current.serial[guid];
            }
        }
    }

    private buffLastExpire: ConditionFunction = (
        positionalParameters,
        namedParameters,
        atTime
    ) => {
        const [spellId] = unpack(positionalParameters);
        const [target, filter, mine] = ParseCondition(
            namedParameters,
            this.baseState
        );
        const aura = this.GetAura(
            target,
            spellId as number,
            atTime,
            filter,
            mine
        );
        if (!aura) return [];
        return ReturnValue(0, aura.ending, 1);
    };

    private ticksGainedOnRefresh: ConditionFunction = () => {
        // TODO see sc_druid.cpp
        return ReturnConstant(0);
    };

    IsActiveAura(aura: Aura, atTime: number): aura is Aura {
        let boolean = false;
        if (aura.state) {
            if (
                aura.serial == this.next.auraSerial &&
                aura.stacks > 0 &&
                aura.gain <= atTime &&
                atTime <= aura.ending
            ) {
                boolean = true;
            } else if (
                aura.consumed &&
                this.IsWithinAuraLag(aura.ending, atTime)
            ) {
                boolean = true;
            }
        } else {
            if (
                aura.serial == this.current.serial[aura.guid] &&
                aura.stacks > 0 &&
                aura.gain <= atTime &&
                atTime <= aura.ending
            ) {
                boolean = true;
            } else if (
                aura.consumed &&
                this.IsWithinAuraLag(aura.ending, atTime)
            ) {
                boolean = true;
            }
        }
        return boolean;
    }

    GainedAuraOnGUID(
        guid: string,
        atTime: number,
        auraId: number,
        casterGUID: string,
        filter: AuraType,
        visible: boolean,
        icon: string | undefined,
        count: number,
        debuffType: string | undefined,
        duration: number,
        expirationTime: number,
        isStealable: boolean,
        name: string,
        value1?: number,
        value2?: number,
        value3?: number
    ) {
        this.profiler.StartProfiling("OvaleAura_GainedAuraOnGUID");
        casterGUID = casterGUID || UNKNOWN_GUID;
        count = (count && count > 0 && count) || 1;
        duration = (duration && duration > 0 && duration) || INFINITY;
        expirationTime =
            (expirationTime && expirationTime > 0 && expirationTime) ||
            INFINITY;
        let aura = GetAura(this.current.aura, guid, auraId, casterGUID);
        let auraIsActive;
        if (aura) {
            auraIsActive =
                aura.stacks > 0 && aura.gain <= atTime && atTime <= aura.ending;
        } else {
            aura = <Aura>self_pool.Get();
            PutAura(this.current.aura, guid, auraId, casterGUID, aura);
            auraIsActive = false;
        }
        const auraIsUnchanged =
            aura.source == casterGUID &&
            aura.duration == duration &&
            aura.ending == expirationTime &&
            aura.stacks == count &&
            aura.value1 == value1 &&
            aura.value2 == value2 &&
            aura.value3 == value3;
        aura.serial = this.current.serial[guid];
        if (!auraIsActive || !auraIsUnchanged) {
            this.debug.Debug(
                "    Adding %s %s (%s) to %s at %f, aura.serial=%d, duration=%f, expirationTime=%f, auraIsActive=%s, auraIsUnchanged=%s",
                filter,
                name,
                auraId,
                guid,
                atTime,
                aura.serial,
                duration,
                expirationTime,
                (auraIsActive && "true") || "false",
                (auraIsUnchanged && "true") || "false"
            );
            aura.name = name;
            aura.duration = duration;
            aura.ending = expirationTime;
            if (duration < INFINITY && expirationTime < INFINITY) {
                aura.start = expirationTime - duration;
            } else {
                aura.start = atTime;
            }
            aura.gain = atTime;
            aura.lastUpdated = atTime;
            let direction = aura.direction || 1;
            if (aura.stacks) {
                if (aura.stacks < count) {
                    direction = 1;
                } else if (aura.stacks > count) {
                    direction = -1;
                }
            }
            aura.direction = direction;
            aura.stacks = count;
            aura.consumed = false;
            aura.filter = filter;
            aura.visible = visible;
            aura.icon = icon;
            aura.debuffType =
                (isString(debuffType) && lower(debuffType)) || debuffType;
            aura.stealable = isStealable;
            [aura.value1, aura.value2, aura.value3] = [value1, value2, value3];
            const mine =
                casterGUID == self_playerGUID ||
                this.ovaleGuid.IsPlayerPet(casterGUID);
            if (mine) {
                let spellcast = this.lastSpell.LastInFlightSpell();
                if (
                    spellcast &&
                    spellcast.stop &&
                    !this.IsWithinAuraLag(spellcast.stop, atTime)
                ) {
                    spellcast = this.lastSpell.lastSpellcast;
                    if (
                        spellcast &&
                        spellcast.stop &&
                        !this.IsWithinAuraLag(spellcast.stop, atTime)
                    ) {
                        spellcast = undefined;
                    }
                }
                if (spellcast && spellcast.target == guid) {
                    const spellId = spellcast.spellId;
                    const spellName =
                        this.ovaleSpellBook.GetSpellName(spellId) ||
                        "Unknown spell";
                    let keepSnapshot = false;
                    const si = this.ovaleData.spellInfo[spellId];
                    if (si && si.aura) {
                        const auraTable =
                            (this.ovaleGuid.IsPlayerPet(guid) && si.aura.pet) ||
                            si.aura.target;
                        if (auraTable && auraTable[filter]) {
                            const spellData = auraTable[filter][auraId];
                            if (
                                spellData &&
                                spellData.cachedParams.named
                                    .refresh_keep_snapshot &&
                                (spellData.cachedParams.named.enabled ===
                                    undefined ||
                                    spellData.cachedParams.named.enabled)
                            ) {
                                keepSnapshot = true;
                            }
                        }
                    }
                    if (keepSnapshot) {
                        this.debug.Debug(
                            "    Keeping snapshot stats for %s %s (%d) on %s refreshed by %s (%d) from %f, now=%f, aura.serial=%d",
                            filter,
                            name,
                            auraId,
                            guid,
                            spellName,
                            spellId,
                            aura.snapshotTime,
                            atTime,
                            aura.serial
                        );
                    } else {
                        this.debug.Debug(
                            "    Snapshot stats for %s %s (%d) on %s applied by %s (%d) from %f, now=%f, aura.serial=%d",
                            filter,
                            name,
                            auraId,
                            guid,
                            spellName,
                            spellId,
                            spellcast.snapshotTime,
                            atTime,
                            aura.serial
                        );
                        this.lastSpell.CopySpellcastInfo(spellcast, aura);
                    }
                }
                const si = this.ovaleData.spellInfo[auraId];
                if (si) {
                    if (si.tick) {
                        this.debug.Debug(
                            "    %s (%s) is a periodic aura.",
                            name,
                            auraId
                        );
                        if (!auraIsActive) {
                            aura.baseTick = si.tick;
                            if (spellcast && spellcast.target == guid) {
                                aura.tick = this.GetTickLength(
                                    auraId,
                                    spellcast
                                );
                            } else {
                                aura.tick = this.GetTickLength(auraId);
                            }
                        }
                    }
                    if (si.buff_cd && guid == self_playerGUID) {
                        this.debug.Debug(
                            "    %s (%s) is applied by an item with a cooldown of %ds.",
                            name,
                            auraId,
                            si.buff_cd
                        );
                        if (!auraIsActive) {
                            aura.cooldownEnding = aura.gain + si.buff_cd;
                        }
                    }
                }
            }
            if (!auraIsActive) {
                this.module.SendMessage(
                    "Ovale_AuraAdded",
                    atTime,
                    guid,
                    auraId,
                    aura.source
                );
            } else if (!auraIsUnchanged) {
                this.module.SendMessage(
                    "Ovale_AuraChanged",
                    atTime,
                    guid,
                    auraId,
                    aura.source
                );
            }
            this.ovale.refreshNeeded[guid] = true;
        }
        this.profiler.StopProfiling("OvaleAura_GainedAuraOnGUID");
    }
    LostAuraOnGUID(
        guid: string,
        atTime: number,
        auraId: AuraId,
        casterGUID: string
    ) {
        this.profiler.StartProfiling("OvaleAura_LostAuraOnGUID");
        const aura = GetAura(this.current.aura, guid, auraId, casterGUID);
        if (aura) {
            const filter = aura.filter;
            this.debug.Debug(
                "    Expiring %s %s (%d) from %s at %f.",
                filter,
                aura.name,
                auraId,
                guid,
                atTime
            );
            if (aura.ending > atTime) {
                aura.ending = atTime;
            }
            const mine =
                casterGUID == self_playerGUID ||
                this.ovaleGuid.IsPlayerPet(casterGUID);
            if (mine) {
                aura.baseTick = undefined;
                aura.lastTickTime = undefined;
                aura.tick = undefined;
                if (aura.start + aura.duration > aura.ending) {
                    let spellcast: SpellCast | undefined;
                    if (guid == self_playerGUID) {
                        spellcast = this.lastSpell.LastSpellSent();
                    } else {
                        spellcast = this.lastSpell.lastSpellcast;
                    }
                    if (spellcast) {
                        if (
                            (spellcast.success &&
                                spellcast.stop &&
                                this.IsWithinAuraLag(
                                    spellcast.stop,
                                    aura.ending
                                )) ||
                            (spellcast.queued &&
                                this.IsWithinAuraLag(
                                    spellcast.queued,
                                    aura.ending
                                ))
                        ) {
                            aura.consumed = true;
                            const spellName =
                                this.ovaleSpellBook.GetSpellName(
                                    spellcast.spellId
                                ) || "Unknown spell";
                            this.debug.Debug(
                                "    Consuming %s %s (%d) on %s with queued %s (%d) at %f.",
                                filter,
                                aura.name,
                                auraId,
                                guid,
                                spellName,
                                spellcast.spellId,
                                spellcast.queued
                            );
                        }
                    }
                }
            }
            aura.lastUpdated = atTime;
            this.module.SendMessage(
                "Ovale_AuraRemoved",
                atTime,
                guid,
                auraId,
                aura.source
            );
            this.ovale.refreshNeeded[guid] = true;
        }
        this.profiler.StopProfiling("OvaleAura_LostAuraOnGUID");
    }
    ScanAuras(unitId: string, guid?: string) {
        this.profiler.StartProfiling("OvaleAura_ScanAuras");
        guid = guid || this.ovaleGuid.UnitGUID(unitId);
        if (guid) {
            const harmfulFilter: UnitAuraFilter =
                (this.ovaleOptions.db.profile.apparence.fullAuraScan &&
                    "HARMFUL") ||
                "HARMFUL|PLAYER";
            const helpfulFilter: UnitAuraFilter =
                (this.ovaleOptions.db.profile.apparence.fullAuraScan &&
                    "HELPFUL") ||
                "HELPFUL|PLAYER";
            this.debug.DebugTimestamp(
                "Scanning auras on %s (%s)",
                guid,
                unitId
            );
            let serial = this.current.serial[guid] || 0;
            serial = serial + 1;
            this.debug.Debug(
                "    Advancing age of auras for %s (%s) to %d.",
                guid,
                unitId,
                serial
            );
            this.current.serial[guid] = serial;
            let i = 1;
            let filter: UnitAuraFilter = helpfulFilter;
            const now = GetTime();
            while (true) {
                let [
                    name,
                    icon,
                    count,
                    debuffType,
                    duration,
                    expirationTime,
                    unitCaster,
                    isStealable,
                    ,
                    spellId,
                    ,
                    ,
                    ,
                    value1,
                    value2,
                    value3,
                ] = UnitAura(unitId, i, filter);
                if (!name) {
                    if (filter == helpfulFilter) {
                        filter = harmfulFilter;
                        i = 1;
                    } else {
                        break;
                    }
                } else {
                    const casterGUID =
                        unitCaster && this.ovaleGuid.UnitGUID(unitCaster);
                    if (casterGUID) {
                        if (debuffType == "") {
                            debuffType = "enrage";
                        }
                        const auraType: AuraType =
                            (filter === harmfulFilter && "HARMFUL") ||
                            "HELPFUL";
                        this.GainedAuraOnGUID(
                            guid,
                            now,
                            spellId,
                            casterGUID,
                            auraType,
                            true,
                            icon,
                            count,
                            debuffType,
                            duration,
                            expirationTime,
                            isStealable,
                            name,
                            value1,
                            value2,
                            value3
                        );
                    }
                    i = i + 1;
                }
            }
            if (this.current.aura[guid]) {
                const auraTable = this.current.aura[guid];
                for (const [auraId, whoseTable] of pairs(auraTable)) {
                    for (const [casterGUID, aura] of pairs(whoseTable)) {
                        if (aura.serial == serial - 1) {
                            if (aura.visible) {
                                this.LostAuraOnGUID(
                                    guid,
                                    now,
                                    tonumber(auraId),
                                    casterGUID
                                );
                            } else {
                                aura.serial = serial;
                                this.debug.Debug(
                                    "    Preserving aura %s (%d), start=%s, ending=%s, aura.serial=%d",
                                    aura.name,
                                    aura.spellId,
                                    aura.start,
                                    aura.ending,
                                    aura.serial
                                );
                            }
                        }
                    }
                }
            }
            this.debug.Debug("End scanning of auras on %s (%s).", guid, unitId);
        }
        this.profiler.StopProfiling("OvaleAura_ScanAuras");
    }

    GetStateAura(
        guid: string,
        auraId: AuraId,
        casterGUID: string,
        atTime: number
    ) {
        const state = this.GetState(atTime);
        let aura = GetAura(state.aura, guid, auraId, casterGUID);
        if (atTime && (!aura || aura.serial < this.next.auraSerial)) {
            aura = GetAura(this.current.aura, guid, auraId, casterGUID);
        }
        if (aura) {
            this.debug.Log("Found aura with stack = %d", aura.stacks);
        }
        return aura;
    }

    DebugUnitAuras(unitId: string, filter: AuraType, atTime: number) {
        wipe(array);
        const guid = this.ovaleGuid.UnitGUID(unitId);
        if (atTime && guid && this.next.aura[guid]) {
            for (const [auraId, whoseTable] of pairs(this.next.aura[guid])) {
                for (const [, aura] of pairs(whoseTable)) {
                    if (
                        this.IsActiveAura(aura, atTime) &&
                        aura.filter == filter &&
                        !aura.state
                    ) {
                        const name = aura.name || "Unknown spell";
                        insert(
                            array,
                            `${name}: ${auraId} ${
                                aura.debuffType || "nil"
                            } enrage=${(aura.debuffType == "enrage" && 1) || 0}`
                        );
                    }
                }
            }
        }
        if (guid && this.current.aura[guid]) {
            for (const [auraId, whoseTable] of pairs(this.current.aura[guid])) {
                for (const [, aura] of pairs(whoseTable)) {
                    if (
                        this.IsActiveAura(aura, atTime) &&
                        aura.filter == filter
                    ) {
                        const name = aura.name || "Unknown spell";
                        insert(
                            array,
                            `${name}: ${auraId} ${
                                aura.debuffType || "nil"
                            } enrage=${(aura.debuffType == "enrage" && 1) || 0}`
                        );
                    }
                }
            }
        }
        if (next(array)) {
            sort(array);
            return concat(array, "\n");
        }
    }

    GetStateAuraAnyCaster(
        guid: string,
        auraId: number | string,
        atTime: number
    ) {
        let auraFound;
        if (this.current.aura[guid] && this.current.aura[guid][auraId]) {
            for (const [, aura] of pairs(this.current.aura[guid][auraId])) {
                if (aura && !aura.state && this.IsActiveAura(aura, atTime)) {
                    if (!auraFound || auraFound.ending < aura.ending) {
                        auraFound = aura;
                    }
                }
            }
        }

        if (atTime && this.next.aura[guid] && this.next.aura[guid][auraId]) {
            for (const [, aura] of pairs(this.next.aura[guid][auraId])) {
                if (aura.stacks > 0) {
                    if (!auraFound || auraFound.ending < aura.ending) {
                        auraFound = aura;
                    }
                }
            }
        }
        return auraFound;
    }

    GetStateDebuffType(
        guid: string,
        debuffType: number | string,
        filter: AuraType | undefined,
        casterGUID: string,
        atTime: number
    ) {
        let auraFound: Aura | undefined = undefined;
        if (this.current.aura[guid]) {
            for (const [, whoseTable] of pairs(this.current.aura[guid])) {
                const aura = whoseTable[casterGUID];
                if (aura && !aura.state && this.IsActiveAura(aura, atTime)) {
                    if (
                        aura.debuffType == debuffType &&
                        aura.filter == filter
                    ) {
                        if (!auraFound || auraFound.ending < aura.ending) {
                            auraFound = aura;
                        }
                    }
                }
            }
        }
        if (atTime && this.next.aura[guid]) {
            for (const [, whoseTable] of pairs(this.next.aura[guid])) {
                const aura = whoseTable[casterGUID];
                if (aura && aura.stacks > 0) {
                    if (
                        aura.debuffType == debuffType &&
                        aura.filter == filter
                    ) {
                        if (!auraFound || auraFound.ending < aura.ending) {
                            auraFound = aura;
                        }
                    }
                }
            }
        }
        return auraFound;
    }
    GetStateDebuffTypeAnyCaster(
        guid: string,
        debuffType: number | string,
        filter: AuraType | undefined,
        atTime: number
    ) {
        let auraFound;
        if (this.current.aura[guid]) {
            for (const [, whoseTable] of pairs(this.current.aura[guid])) {
                for (const [, aura] of pairs(whoseTable)) {
                    if (
                        aura &&
                        !aura.state &&
                        this.IsActiveAura(aura, atTime)
                    ) {
                        if (
                            aura.debuffType == debuffType &&
                            aura.filter == filter
                        ) {
                            if (!auraFound || auraFound.ending < aura.ending) {
                                auraFound = aura;
                            }
                        }
                    }
                }
            }
        }
        if (atTime && this.next.aura[guid]) {
            for (const [, whoseTable] of pairs(this.next.aura[guid])) {
                for (const [, aura] of pairs(whoseTable)) {
                    if (aura && !aura.state && aura.stacks > 0) {
                        if (
                            aura.debuffType == debuffType &&
                            aura.filter == filter
                        ) {
                            if (!auraFound || auraFound.ending < aura.ending) {
                                auraFound = aura;
                            }
                        }
                    }
                }
            }
        }
        return auraFound;
    }
    GetStateAuraOnGUID(
        guid: string,
        auraId: AuraId,
        filter: AuraType | undefined,
        mine: boolean | undefined,
        atTime: number
    ) {
        let auraFound: Aura | undefined = undefined;
        if (DEBUFF_TYPE[auraId]) {
            if (mine) {
                auraFound = this.GetStateDebuffType(
                    guid,
                    auraId,
                    filter,
                    self_playerGUID,
                    atTime
                );
                if (!auraFound) {
                    for (const [petGUID] of pairs(self_petGUID)) {
                        const aura = this.GetStateDebuffType(
                            guid,
                            auraId,
                            filter,
                            petGUID,
                            atTime
                        );
                        if (
                            aura &&
                            (!auraFound || auraFound.ending < aura.ending)
                        ) {
                            auraFound = aura;
                        }
                    }
                }
            } else {
                auraFound = this.GetStateDebuffTypeAnyCaster(
                    guid,
                    auraId,
                    filter,
                    atTime
                );
            }
        } else {
            if (mine) {
                let aura = this.GetStateAura(
                    guid,
                    auraId,
                    self_playerGUID,
                    atTime
                );
                if (aura && aura.stacks > 0) {
                    auraFound = aura;
                } else {
                    for (const [petGUID] of pairs(self_petGUID)) {
                        aura = this.GetStateAura(guid, auraId, petGUID, atTime);
                        if (aura && aura.stacks > 0) {
                            auraFound = aura;
                            break;
                        }
                    }
                }
            } else {
                auraFound = this.GetStateAuraAnyCaster(guid, auraId, atTime);
            }
        }
        return auraFound;
    }

    GetAuraByGUID(
        guid: string,
        auraId: AuraId,
        filter: AuraType | undefined,
        mine: boolean | undefined,
        atTime: number
    ) {
        let auraFound: Aura | undefined = undefined;
        if (this.ovaleData.buffSpellList[auraId]) {
            for (const [id] of pairs(this.ovaleData.buffSpellList[auraId])) {
                // TODO check this tostring(id)
                const aura = this.GetStateAuraOnGUID(
                    guid,
                    id,
                    filter,
                    mine,
                    atTime
                );
                if (aura && (!auraFound || auraFound.ending < aura.ending)) {
                    this.debug.Log(
                        "Aura %s matching '%s' found on %s with (%s, %s)",
                        id,
                        auraId,
                        guid,
                        aura.start,
                        aura.ending
                    );
                    auraFound = aura;
                }
            }
            if (!auraFound) {
                this.debug.Log(
                    "Aura matching '%s' is missing on %s.",
                    auraId,
                    guid
                );
            }
        } else {
            auraFound = this.GetStateAuraOnGUID(
                guid,
                auraId,
                filter,
                mine,
                atTime
            );
            if (auraFound) {
                this.debug.Log(
                    "Aura %s found on %s with (%s, %s) [stacks=%d]",
                    auraId,
                    guid,
                    auraFound.start,
                    auraFound.ending,
                    auraFound.stacks
                );
            } else {
                this.debug.Log(
                    "Aura %s is missing on %s (mine=%s).",
                    auraId,
                    guid,
                    mine
                );
            }
        }
        return auraFound;
    }

    GetAura(
        unitId: string,
        auraId: AuraId,
        atTime: number,
        filter?: AuraType,
        mine?: boolean
    ) {
        const guid = this.ovaleGuid.UnitGUID(unitId);
        if (!guid) return;
        if (isNumber(auraId)) this.ovaleData.registerAuraAsked(auraId);
        return this.GetAuraByGUID(guid, auraId, filter, mine, atTime);
    }

    GetAuraWithProperty(
        unitId: string,
        propertyName: keyof Aura,
        filter: AuraType,
        atTime: number
    ): ConditionResult {
        let count = 0;
        const guid = this.ovaleGuid.UnitGUID(unitId);
        if (!guid) return [];
        let start: number = huge;
        let ending = 0;
        if (this.current.aura[guid]) {
            for (const [, whoseTable] of pairs(this.current.aura[guid])) {
                for (const [, aura] of pairs(whoseTable)) {
                    if (this.IsActiveAura(aura, atTime) && !aura.state) {
                        if (aura[propertyName] && aura.filter == filter) {
                            count = count + 1;
                            start = (aura.gain < start && aura.gain) || start;
                            ending =
                                (aura.ending > ending && aura.ending) || ending;
                        }
                    }
                }
            }
        }
        if (this.next.aura[guid]) {
            for (const [, whoseTable] of pairs(this.next.aura[guid])) {
                for (const [, aura] of pairs(whoseTable)) {
                    if (this.IsActiveAura(aura, atTime)) {
                        if (aura[propertyName] && aura.filter == filter) {
                            count = count + 1;
                            start = (aura.gain < start && aura.gain) || start;
                            ending =
                                (aura.ending > ending && aura.ending) || ending;
                        }
                    }
                }
            }
        }
        if (count > 0) {
            this.debug.Log(
                "Aura with '%s' property found on %s (count=%s, minStart=%s, maxEnding=%s).",
                propertyName,
                unitId,
                count,
                start,
                ending
            );
        } else {
            this.debug.Log(
                "Aura with '%s' property is missing on %s.",
                propertyName,
                unitId
            );
            return [];
        }
        return [start, ending];
    }

    AuraCount(
        auraId: number,
        filter: AuraType | undefined,
        mine: boolean,
        minStacks: number | undefined,
        atTime: number,
        excludeUnitId: string | undefined
    ) {
        this.profiler.StartProfiling("OvaleAura_state_AuraCount");
        minStacks = minStacks || 1;
        count = 0;
        stacks = 0;
        [startChangeCount, endingChangeCount] = [huge, huge];
        [startFirst, endingLast] = [huge, 0];
        const excludeGUID =
            (excludeUnitId && this.ovaleGuid.UnitGUID(excludeUnitId)) ||
            undefined;
        for (const [guid, auraTable] of pairs(this.current.aura)) {
            if (guid != excludeGUID && auraTable[auraId]) {
                if (mine && self_playerGUID) {
                    let aura = this.GetStateAura(
                        guid,
                        auraId,
                        self_playerGUID,
                        atTime
                    );
                    if (
                        aura &&
                        this.IsActiveAura(aura, atTime) &&
                        aura.filter == filter &&
                        aura.stacks >= minStacks &&
                        !aura.state
                    ) {
                        this.CountMatchingActiveAura(aura);
                    }
                    for (const [petGUID] of pairs(self_petGUID)) {
                        aura = this.GetStateAura(guid, auraId, petGUID, atTime);
                        if (
                            aura &&
                            this.IsActiveAura(aura, atTime) &&
                            aura.filter == filter &&
                            aura.stacks >= minStacks &&
                            !aura.state
                        ) {
                            this.CountMatchingActiveAura(aura);
                        }
                    }
                } else {
                    for (const [casterGUID] of pairs(auraTable[auraId])) {
                        const aura = this.GetStateAura(
                            guid,
                            auraId,
                            casterGUID,
                            atTime
                        );
                        if (
                            aura &&
                            this.IsActiveAura(aura, atTime) &&
                            aura.filter == filter &&
                            aura.stacks >= minStacks &&
                            !aura.state
                        ) {
                            this.CountMatchingActiveAura(aura);
                        }
                    }
                }
            }
        }
        for (const [guid, auraTable] of pairs(this.next.aura)) {
            if (guid != excludeGUID && auraTable[auraId]) {
                if (mine) {
                    let aura = auraTable[auraId][self_playerGUID];
                    if (aura) {
                        if (
                            this.IsActiveAura(aura, atTime) &&
                            aura.filter == filter &&
                            aura.stacks >= minStacks
                        ) {
                            this.CountMatchingActiveAura(aura);
                        }
                    }
                    for (const [petGUID] of pairs(self_petGUID)) {
                        aura = auraTable[auraId][petGUID];
                        if (
                            aura &&
                            this.IsActiveAura(aura, atTime) &&
                            aura.filter == filter &&
                            aura.stacks >= minStacks &&
                            !aura.state
                        ) {
                            this.CountMatchingActiveAura(aura);
                        }
                    }
                } else {
                    for (const [, aura] of pairs(auraTable[auraId])) {
                        if (
                            aura &&
                            this.IsActiveAura(aura, atTime) &&
                            aura.filter == filter &&
                            aura.stacks >= minStacks
                        ) {
                            this.CountMatchingActiveAura(aura);
                        }
                    }
                }
            }
        }
        this.debug.Log(
            "AuraCount(%d) is %s, %s, %s, %s, %s, %s",
            auraId,
            count,
            stacks,
            startChangeCount,
            endingChangeCount,
            startFirst,
            endingLast
        );
        this.profiler.StopProfiling("OvaleAura_state_AuraCount");
        return [
            count,
            stacks,
            startChangeCount,
            endingChangeCount,
            startFirst,
            endingLast,
        ];
    }

    InitializeState() {
        this.next.aura = {};
        this.next.auraSerial = 0;
        self_playerGUID = this.ovale.playerGUID;
    }
    ResetState() {
        this.profiler.StartProfiling("OvaleAura_ResetState");
        this.next.auraSerial = this.next.auraSerial + 1;
        if (next(this.next.aura)) {
            this.debug.Log("Resetting aura state:");
        }
        for (const [guid, auraTable] of pairs(this.next.aura)) {
            for (const [auraId, whoseTable] of pairs(auraTable)) {
                for (const [casterGUID, aura] of pairs(whoseTable)) {
                    self_pool.Release(aura);
                    delete whoseTable[casterGUID];
                    this.debug.Log("    Aura %d on %s removed.", auraId, guid);
                }
                if (!next(whoseTable)) {
                    self_pool.Release(whoseTable);
                    delete auraTable[auraId];
                }
            }
            if (!next(auraTable)) {
                self_pool.Release(auraTable);
                delete this.next.aura[guid];
            }
        }
        this.profiler.StopProfiling("OvaleAura_ResetState");
    }
    CleanState() {
        for (const [guid] of pairs(this.next.aura)) {
            RemoveAurasOnGUID(this.next.aura, guid);
        }
    }
    ApplySpellStartCast = (
        spellId: number,
        targetGUID: string,
        startCast: number,
        endCast: number,
        isChanneled: boolean,
        spellcast: SpellCast
    ) => {
        this.profiler.StartProfiling("OvaleAura_ApplySpellStartCast");
        if (isChanneled) {
            const si = this.ovaleData.spellInfo[spellId];
            if (si && si.aura) {
                if (si.aura.player) {
                    this.ApplySpellAuras(
                        spellId,
                        self_playerGUID,
                        startCast,
                        si.aura.player,
                        spellcast
                    );
                }
                if (si.aura.target) {
                    this.ApplySpellAuras(
                        spellId,
                        targetGUID,
                        startCast,
                        si.aura.target,
                        spellcast
                    );
                }
                if (si.aura.pet) {
                    const petGUID = this.ovaleGuid.UnitGUID("pet");
                    if (petGUID) {
                        this.ApplySpellAuras(
                            spellId,
                            petGUID,
                            startCast,
                            si.aura.pet,
                            spellcast
                        );
                    }
                }
            }
        }
        this.profiler.StopProfiling("OvaleAura_ApplySpellStartCast");
    };
    ApplySpellAfterCast = (
        spellId: number,
        targetGUID: string,
        startCast: number,
        endCast: number,
        isChanneled: boolean,
        spellcast: SpellCast
    ) => {
        this.profiler.StartProfiling("OvaleAura_ApplySpellAfterCast");
        if (!isChanneled) {
            const si = this.ovaleData.spellInfo[spellId];
            if (si && si.aura) {
                if (si.aura.player) {
                    this.ApplySpellAuras(
                        spellId,
                        self_playerGUID,
                        endCast,
                        si.aura.player,
                        spellcast
                    );
                }
                if (si.aura.pet) {
                    const petGUID = this.ovaleGuid.UnitGUID("pet");
                    if (petGUID) {
                        this.ApplySpellAuras(
                            spellId,
                            petGUID,
                            startCast,
                            si.aura.pet,
                            spellcast
                        );
                    }
                }
            }
        }
        this.profiler.StopProfiling("OvaleAura_ApplySpellAfterCast");
    };
    ApplySpellOnHit = (
        spellId: number,
        targetGUID: string,
        startCast: number,
        endCast: number,
        isChanneled: boolean,
        spellcast: SpellCast
    ) => {
        this.profiler.StartProfiling("OvaleAura_ApplySpellAfterHit");
        if (!isChanneled) {
            const si = this.ovaleData.spellInfo[spellId];
            if (si && si.aura && si.aura.target) {
                let travelTime = si.travel_time || 0;
                if (travelTime > 0) {
                    const estimatedTravelTime = 1;
                    if (travelTime < estimatedTravelTime) {
                        travelTime = estimatedTravelTime;
                    }
                }
                const atTime = endCast + travelTime;
                this.ApplySpellAuras(
                    spellId,
                    targetGUID,
                    atTime,
                    si.aura.target,
                    spellcast
                );
            }
        }
        this.profiler.StopProfiling("OvaleAura_ApplySpellAfterHit");
    };

    private ApplySpellAuras(
        spellId: number,
        guid: string,
        atTime: number,
        auraList: SpellAddAurasByType,
        spellcast: SpellCast
    ) {
        this.profiler.StartProfiling("OvaleAura_state_ApplySpellAuras");
        for (const [filter, filterInfo] of kpairs(auraList)) {
            for (const [auraIdKey, spellData] of pairs(filterInfo)) {
                const auraId = tonumber(auraIdKey);
                const duration = this.GetBaseDuration(auraId, spellcast);
                let stacks = 1;
                let count: number | undefined = undefined;
                let extend = 0;
                let toggle = undefined;
                let refresh = false;
                let keepSnapshot = false;
                const data = this.ovaleData.CheckSpellAuraData(
                    auraId,
                    spellData,
                    atTime,
                    guid
                );
                if (data.refresh) {
                    refresh = true;
                } else if (data.refresh_keep_snapshot) {
                    refresh = true;
                    keepSnapshot = true;
                } else if (data.toggle) {
                    toggle = true;
                } else if (isNumber(data.set)) {
                    count = data.set;
                } else if (isNumber(data.extend)) {
                    extend = data.extend;
                } else if (isNumber(data.add)) {
                    stacks = data.add;
                } else {
                    this.debug.Log("Aura has nothing defined");
                }
                if (data.enabled === undefined || data.enabled) {
                    const si = this.ovaleData.spellInfo[auraId];
                    const auraFound = this.GetAuraByGUID(
                        guid,
                        auraId,
                        filter,
                        true,
                        atTime
                    );
                    if (auraFound && this.IsActiveAura(auraFound, atTime)) {
                        let aura: Aura;
                        if (auraFound.state) {
                            aura = auraFound;
                        } else {
                            aura = this.AddAuraToGUID(
                                guid,
                                auraId,
                                auraFound.source,
                                filter,
                                undefined,
                                0,
                                huge,
                                atTime
                            );
                            for (const [k, v] of kpairs(auraFound)) {
                                (<any>aura)[k] = v;
                            }
                            aura.serial = this.next.auraSerial;
                            this.debug.Log(
                                "Aura %d is copied into simulator.",
                                auraId
                            );
                        }
                        if (toggle) {
                            this.debug.Log(
                                "Aura %d is toggled off by spell %d.",
                                auraId,
                                spellId
                            );
                            stacks = 0;
                        }
                        if (count && count > 0) {
                            stacks = count - aura.stacks;
                        }
                        if (refresh || extend > 0 || stacks > 0) {
                            if (refresh) {
                                this.debug.Log(
                                    "Aura %d is refreshed to %d stack(s).",
                                    auraId,
                                    aura.stacks
                                );
                            } else if (extend > 0) {
                                this.debug.Log(
                                    "Aura %d is extended by %f seconds, preserving %d stack(s).",
                                    auraId,
                                    extend,
                                    aura.stacks
                                );
                            } else {
                                let maxStacks = 1;
                                if (si && si.max_stacks) {
                                    maxStacks = si.max_stacks;
                                }
                                aura.stacks = aura.stacks + stacks;
                                if (aura.stacks > maxStacks) {
                                    aura.stacks = maxStacks;
                                }
                                this.debug.Log(
                                    "Aura %d gains %d stack(s) to %d because of spell %d.",
                                    auraId,
                                    stacks,
                                    aura.stacks,
                                    spellId
                                );
                            }
                            if (extend > 0) {
                                aura.duration = aura.duration + extend;
                                aura.ending = aura.ending + extend;
                            } else {
                                aura.start = atTime;
                                if (aura.tick && aura.tick > 0) {
                                    const remainingDuration =
                                        aura.ending - atTime;
                                    const extensionDuration = 0.3 * duration;
                                    if (remainingDuration < extensionDuration) {
                                        aura.duration =
                                            remainingDuration + duration;
                                    } else {
                                        aura.duration =
                                            extensionDuration + duration;
                                    }
                                } else {
                                    aura.duration = duration;
                                }
                                aura.ending = aura.start + aura.duration;
                            }
                            aura.gain = atTime;
                            this.debug.Log(
                                "Aura %d with duration %s now ending at %s",
                                auraId,
                                aura.duration,
                                aura.ending
                            );
                            if (keepSnapshot) {
                                this.debug.Log(
                                    "Aura %d keeping previous snapshot.",
                                    auraId
                                );
                            } else if (spellcast) {
                                this.lastSpell.CopySpellcastInfo(
                                    spellcast,
                                    aura
                                );
                            }
                        } else if (stacks == 0 || stacks < 0) {
                            if (stacks == 0) {
                                aura.stacks = 0;
                            } else {
                                aura.stacks = aura.stacks + stacks;
                                if (aura.stacks < 0) {
                                    aura.stacks = 0;
                                }
                                this.debug.Log(
                                    "Aura %d loses %d stack(s) to %d because of spell %d.",
                                    auraId,
                                    -1 * stacks,
                                    aura.stacks,
                                    spellId
                                );
                            }
                            if (aura.stacks == 0) {
                                this.debug.Log(
                                    "Aura %d is completely removed.",
                                    auraId
                                );
                                aura.ending = atTime;
                                aura.consumed = true;
                            }
                        }
                    } else {
                        if (toggle) {
                            this.debug.Log(
                                "Aura %d is toggled on by spell %d.",
                                auraId,
                                spellId
                            );
                            stacks = 1;
                        }
                        if (!refresh && stacks > 0) {
                            this.debug.Log(
                                "New aura %d at %f on %s",
                                auraId,
                                atTime,
                                guid
                            );
                            let debuffType;
                            if (si) {
                                for (const [k, v] of pairs(
                                    SPELLINFO_DEBUFF_TYPE
                                )) {
                                    if (si[k as keyof SpellInfo] == 1) {
                                        debuffType = v;
                                        break;
                                    }
                                }
                            }
                            const aura = this.AddAuraToGUID(
                                guid,
                                auraId,
                                self_playerGUID,
                                filter,
                                debuffType,
                                0,
                                huge,
                                atTime
                            );
                            aura.stacks = stacks;
                            aura.start = atTime;
                            aura.duration = duration;
                            if (si && si.tick) {
                                aura.baseTick = si.tick;
                                aura.tick = this.GetTickLength(
                                    auraId,
                                    spellcast
                                );
                            }
                            aura.ending = aura.start + aura.duration;
                            aura.gain = aura.start;
                            if (spellcast) {
                                this.lastSpell.CopySpellcastInfo(
                                    spellcast,
                                    aura
                                );
                            }
                        }
                    }
                } else {
                    this.debug.Log(
                        "Aura %d (%s) is not applied.",
                        auraId,
                        spellData
                    );
                }
            }
        }
        this.profiler.StopProfiling("OvaleAura_state_ApplySpellAuras");
    }

    public AddAuraToGUID(
        guid: string,
        auraId: AuraId,
        casterGUID: string,
        filter: AuraType,
        debuffType: string | undefined,
        start: number,
        ending: number,
        atTime: number,
        snapshot?: PaperDollSnapshot
    ) {
        const aura = <Aura>self_pool.Get();
        aura.state = true;
        aura.serial = this.next.auraSerial;
        aura.lastUpdated = atTime;
        aura.filter = filter;
        aura.start = start || 0;
        aura.ending = ending || huge;
        aura.duration = aura.ending - aura.start;
        aura.gain = aura.start;
        aura.stacks = 1;
        aura.debuffType =
            (isString(debuffType) && lower(debuffType)) || debuffType;
        this.ovalePaperDoll.UpdateSnapshot(aura, snapshot);
        PutAura(this.next.aura, guid, auraId, casterGUID, aura);
        return aura;
    }
    RemoveAuraOnGUID(
        guid: string,
        auraId: AuraId,
        filter: AuraType,
        mine: boolean,
        atTime: number
    ) {
        const auraFound = this.GetAuraByGUID(
            guid,
            auraId,
            filter,
            mine,
            atTime
        );
        if (auraFound && this.IsActiveAura(auraFound, atTime)) {
            let aura;
            if (auraFound.state) {
                aura = auraFound;
            } else {
                aura = this.AddAuraToGUID(
                    guid,
                    auraId,
                    auraFound.source,
                    filter,
                    undefined,
                    0,
                    huge,
                    atTime
                );
                for (const [k, v] of kpairs(auraFound)) {
                    (<any>aura)[k] = v;
                }
                aura.serial = this.next.auraSerial;
            }
            aura.stacks = 0;
            aura.ending = atTime;
            aura.lastUpdated = atTime;
        }
    }

    GetBaseDuration(auraId: number, spellcast?: PaperDollSnapshot) {
        spellcast = spellcast || this.ovalePaperDoll.current;
        const combopoints = spellcast.combopoints || 0;
        let duration = INFINITY;
        const si = this.ovaleData.spellInfo[auraId];
        if (si && si.duration) {
            const [value, ratio] = this.ovaleData.GetSpellInfoPropertyNumber(
                auraId,
                undefined,
                "duration",
                undefined,
                true
            ) || [15, 1];
            if (si.add_duration_combopoints && combopoints) {
                duration =
                    (value + si.add_duration_combopoints * combopoints) * ratio;
            } else {
                duration = value * ratio;
            }
        }
        // Most aura durations are no longer reduced by haste
        // but the ones that do still need their reduction
        if (si && si.haste && spellcast) {
            const hasteMultiplier = this.ovalePaperDoll.GetHasteMultiplier(
                si.haste,
                spellcast
            );
            duration = duration / hasteMultiplier;
        }
        return duration;
    }
    GetTickLength(auraId: number, snapshot?: PaperDollSnapshot) {
        snapshot = snapshot || this.ovalePaperDoll.current;
        let tick = 3;
        const si = this.ovaleData.spellInfo[auraId];
        if (si) {
            tick = si.tick || tick;
            const hasteMultiplier = this.ovalePaperDoll.GetHasteMultiplier(
                si.haste,
                snapshot
            );
            tick = tick / hasteMultiplier;
        }
        return tick;
    }
}
// DO NOT EDIT THIS FILE. Edit the en-US.json file and run yarn localize
import { LocalizationStrings } from "./definition";

export function getENUS(): Required<LocalizationStrings> {
    return {
        action_bar: `Action bar`,
        show_cooldown: `Numeric display`,
        show_cooldown_help: `Show the remaining time in numerical form`,
        two_icons: `Display two abilities and not only one`,
        show_frame: `Show Ovale`,
        show_keyboard_shortcuts: `Show keyboard shortcuts in the icon bottom-left corner`,
        aoe: `Attack multiple targets.
Adapts to the total number of enemies.`,
        appearance: `Appearance`,
        arcane_mage_burn_phase: `Suggest Burn actions`,
        artifact_traits: `Artifact traits`,
        aura_lag: `Aura lag`,
        auras_player: `Auras (player)`,
        auras_target: `Auras (target)`,
        auras_on_player: `Auras on the player`,
        auras_on_target: `Auras on the target`,
        blood: `Blood`,
        buff: `Buffs`,
        hide_empty_buttons: `Hide empty buttons`,
        hide_in_vehicles: `Hide in vehicles`,
        hide_frame: `Hide Ovale`,
        hide_if_dead_or_friendly_target: `Hide if friendly or dead target`,
        range_indicator: `Range indicator`,
        cd: `Long cooldown abilities.
Cast as soon as possible or for increased-damage phases.`,
        range_indicator_help: `This text is displayed on the icon to show if the target is in range`,
        script_tooltip: `Click to select the script.`,
        options_tooltip: `Click to hide/show options`,
        code: `Code`,
        colors: `Colors`,
        copy_to_custom_script: `Copy to custom script`,
        latency_correction: `Latency correction`,
        debug: `Debug`,
        debug_aura: `Track aura management.`,
        debug_compile: `Track when the script is compiled.`,
        debug_enemies: `Track enemy detection.`,
        debug_guid: `Track changes to the UnitID/GUID pairings.`,
        debug_missing_spells: `Warn if a known spell ID is used that is missing from the spellbook.`,
        debug_unknown_spells: `Warn if an unknown spell ID is used in the script.`,
        options_horizontal_shift: `Options horizontal shift`,
        options_vertical_shift: `Options vertical shift`,
        scrolling: `Scrolling`,
        disabled: `Disabled`,
        display_refresh_statistics: `Display refresh statistics`,
        overwrite_existing_script: `Overwrite existing custom script?`,
        combat_only: `Show in combat only`,
        enable_debug_messages: `Enable debugging messages for the %s module.`,
        enable_profiling: `Enable profiling for the %s module.`,
        enabled: `Enabled`,
        flash_brightness: `Flash brightness`,
        flash_size: `Flash size`,
        flash_spells: `Flash spells`,
        flash_spells_help: `Flash spells on action bars when they are ready to be cast. Requires SpellFlashCore`,
        flash_threshold: `Flash threshold`,
        focus: `Focus`,
        icon_group: `Icon group`,
        horizontal_offset: `Horizontal offset`,
        horizontal_offset_help: `Horizontal offset from the center of the screen.`,
        icon: `Icon`,
        ignore_mouse_clicks: `Ignore mouse clicks`,
        highlight_icon: `Highlight icon`,
        highlight_icon_help: `Hightlight icon when ability should be spammed`,
        highlight_icon_on_cd: `Flash the icon when the ability is ready`,
        input: `Input`,
        interrupt: `Interrupts`,
        interrupts: `Interrupts`,
        check_box_tooltip: `Toggle check box`,
        icon_scale_help: `The icons scale`,
        small_icon_scale_help: `The small icons scale`,
        font_scale_help: `The font scale`,
        lag_threshold: `Lag (in milliseconds) between when an spell is cast and when the affected aura is applied or removed`,
        layout: `Layout`,
        scrolling_help: `Scroll the icons`,
        long_cd: `Long cooldown abilities`,
        main: `Main attack`,
        main_attack: `Main attack`,
        mana: `Mana gain`,
        margin_between_icons: `Margin between icons`,
        middle_click_help: `Middle-Click to toggle the script options panel.`,
        modules: `Modules`,
        moving: `Attacks to use while moving`,
        multidot: `Damage-over-time on multiple targets`,
        none: `None`,
        not_in_melee_range: `Not in melee range`,
        offgcd: `Out of global cooldown ability.
Cast alongside your main attack.`,
        only_tagged_help: `Only count a mob as an enemy if it is directly affected by a player's spells.`,
        only_tagged: `Only count tagged enemies`,
        icon_opacity: `Icons opacity`,
        option_opacity: `Options opacity`,
        movable_configuration_pannel: `Open configuration panel in a separate, movable window.`,
        options: `Options`,
        output: `Output`,
        overrides: `Overrides`,
        ping_users: `Ping for Ovale users in group`,
        power: `Power`,
        predict: `Next non-filler attack.`,
        two_abilities: `Two abilities`,
        profiling: `Profiling`,
        keyboard_shortcuts: `Keyboard shortcuts`,
        reset: `Reset`,
        reset_profiling: `Reset the profiling statistics.`,
        right_click_help: `Right-Click for options.`,
        script: `Script`,
        default_script: `Default script`,
        custom_script: `Custom script`,
        shift_right_click_help: `Shift-Right-Click for the current trace log.`,
        short_cd: `Short cooldown abilities`,
        shortcd: `Short cooldown abilities.
Cast as soon as possible.`,
        show: `Show`,
        show_hidden: `Show hidden`,
        show_minimap_icon: `Show minimap icon`,
        show_profiling_statistics: `Show the profiling statistics.`,
        show_trace_log: `Show Trace Log`,
        show_version_number: `Show version number`,
        showwait: `Show the wait icon`,
        if_target: `If has target`,
        simulationcraft_profile: `SimulationCraft Profile`,
        simulationcraft_overrides_description: `Script code inserted immediately after Include() script statements to override standard definitions, e.g., |cFFFFFF00SpellInfo(tigers_fury tag=main)|r`,
        spellbook: `Spellbook`,
        stances: `Stances`,
        standalone_options: `Standalone options`,
        summon_pet: `Summon pet.`,
        icon_scale: `Icon scale`,
        small_icon_scale: `Small icon scale`,
        font_scale: `Font scale`,
        second_icon_scale: `Second icon size`,
        talents: `Talents`,
        simulationcraft_profile_content: `The contents of a SimulationCraft profile.`,
        simulationcraft_profile_translated: `The script translated from the SimulationCraft profile.`,
        flash_time: `Time (in milliseconds) to begin flashing the spell to use before it is ready.`,
        top_3: `Top 3`,
        trace: `Trace`,
        trace_log: `Trace Log`,
        trace_next_frame: `Trace the next frame update.`,
        lock_position: `Lock position`,
        vertical: `Vertical`,
        vertical_offset: `Vertical offset`,
        vertical_offset_help: `Vertical offset from the center of the screen.`,
        visibility: `Visibility`,
        frequent_health_updates: `Frequent health updates`,
        frequent_health_updates_help: `Updates health of units more frquently; enabling this may reduce FPS.`,
        max_refresh: `Max refresh`,
        min_refresh: `Min Refresh`,
        min_refresh_help: `Minimum time (in milliseconds) between updates; lower values may reduce FPS.`,
        scan_all_auras_help: `Scans also buffs/debuffs casted by other players or NPCs.

Warning!: Very CPU intensive`,
        scan_all_auras: `Full buffs/debuffs scan`,
        remaining_time_font_color: `Remaining time font color`,
        icon_snapshot: `Icon nodes snapshot`,

    };
}
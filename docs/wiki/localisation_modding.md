# Stellaris Localisation Modding Reference

> Source: https://stellaris.paradoxwikis.com/Localisation_modding

## File Setup

**Directory:** `localisation/` in mod root (British spelling with 's')

**File naming:** `<filename>_l_<language>.yml`

**Encoding:** UTF-8 with BOM (not standard UTF-8). First line must be `l_<language>:`

**Supported Languages:** braz_por, english, french, german, polish, russian, spanish, simp_chinese, japanese, korean

## YAML Syntax

```yaml
l_english:
 key_name: "Display text here"
 another_key: "More text"
```

**Rules:**
- Each entry requires leading whitespace (space/tab)
- Escape quotes with backslash: `\"quoted text\"`
- Invalid unicode characters: ,,, -- " ' ... ---

## Bracket Commands [Scoped Localization]

Format: `[PrimaryScope.SecondaryScope.TextRetrieval]`

### Primary Scopes
- `[Root.GetName]` - event root
- `[This.GetName]` - current scope
- `[From.GetName]` - calling event root
- `[Prev.GetName]` - previous scope
- Event targets: `[mytarget.GetName]` (without `event_target:` prefix)
- Diplomatic: `[Actor.GetName]`, `[Recipient.GetName]`, `[Third_party.GetName]`

### Secondary Scopes (Promotions)
- `Capital`, `Leader`, `Ruler`, `Heir`, `Species`, `Federation`
- `Owner`, `System`, `Planet`
- `MainAttacker`, `MainDefender` (war scopes)

### Text Retrieval
- `GetName` - associated name
- `GetAdj` / `GetAdjective` - adjective form
- `GetSpeciesName` - species name
- `GetRulerTitle` - ruler's title
- `GetIsAre` - "is"/"are" (gender-aware)
- `GetHasHave` - "has"/"have"
- `GetSheHe` / `GetHerHim` / `GetHerHis` - pronouns
- `GetAge` - leader age
- `GetPlanetMoon` - "planet"/"moon"

Escape brackets: `[[example]` displays as `[example]`

## Dollar Sign ($) Codes

Format: `$VARIABLE_NAME$` or `$VARIABLE|*decimals$`

Number formatting:
- `$VALUE|*0$` - no decimals (100)
- `$VALUE|*1$` - one decimal (100.0)

## Pound Sign (GBP) Codes

Format: `£iconname£` (Windows: Alt+0163)

### Common Icons
- `£energy£`, `£minerals£`, `£food£`, `£influence£`
- `£stability£`, `£unity£`, `£alloys£`, `£trade_value£`
- `£physics£`, `£society£`, `£engineering£`
- `£pops£`, `£happiness£`, `£opinion£`
- `£military_ship£`, `£military_power£`, `£time£`

### Custom Icons
1. Save 16x16 .dds file in `gfx/interface/icons/text_icons/`
2. Define in `.gfx` file:
```
spriteTypes = {
    spriteType = {
        name = "GFX_text_myicon"
        texturefile = "gfx/interface/icons/text_icons/myicon.dds"
    }
}
```
3. Reference as `£myicon£`

## Color Codes

Format: `§X` (Windows: Alt+0167) where X is color character

| Code | Color | Use |
|------|-------|-----|
| W | White | Diplomatic attitudes |
| T | Light Grey | Standard text |
| g | Dark Grey | Disabled/inactive |
| L | Brown/Kaki | Lore/roleplay |
| R | Red | Negative modifiers |
| H/K | Mango/Orange | Highlights |
| Y/I | Yellow | Neutral/sub-optimal |
| G | Green | Positive |
| E | Teal | Large text chunks |
| C | Cyan | Concept text/tooltips |
| B | Cyan-Blue | Pop effects |
| M | Purple | Rare tech |
| ! | Default | Return to previous |

Within $ commands, specify color with pipe: `$AGE|Y$`

## Special Slash Codes

- `\n` - newline
- `\t` - tab
- `\"` - literal quotation mark

## Overwriting Vanilla Localisation

**Recommended: Replace folder method**
- Create `localisation/replace/` folder
- Files here load last and overwrite duplicate keys (LIOS principle)

**Full file override** (not recommended unless changing most entries):
- Name file identically to vanilla file

## Console Commands

- `reload text` - reloads localisation
- `switchlanguage l_english` - switch language
- `toggle_string_id` - displays StringID instead of text

## Style Guide

| Element | Capitalization | Char Limit |
|---------|---------------|-----------|
| Event Names | Title Case | ~50 |
| Event Descriptions | Sentence case | ~2000 |
| Event Options | Sentence case | ~70 |
| Traits/Modifiers/Buildings | Title Case | ~30 |
| Descriptions | Sentence case | ~200 |

## Important Notes

- Always verify file encoding: UTF-8 without BOM will fail silently
- Use `replace/` folder for reliable individual key overwriting
- No fallback language system — missing keys display as raw text
- Variables can be referenced: `[Scope.my_variable]`
- Saved dates accessible: `[Scope.my_date_flag]` (v3.1+)

## See Also
- [Scopes](scopes.md) — scope system used in bracket commands `[Scope.GetName]`
- [Dynamic Modding](dynamic_modding.md) — scripted localization (`defined_text`)
- [Event Modding](event_modding.md) — events that need localisation for titles, desc, options
- [Variables](variables.md) — displaying variables in loc: `[This.my_var]`

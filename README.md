# Quran Data Repository

This repository serves as the **static data source (CDN)** for the [Quran App](https://github.com/hamas/Quran).

It contains:
- **Fonts**: Dynamic font files (e.g., KFGQPC, Indopak) loaded on demand.
- **Translations**: JSON files for various language translations.
- **Metadata**: Index files (`languages.json`) used by the app to discover available resources.

## Usage
The Quran App fetches the `languages.json` index to list available downloads.
Direct links to raw files are used for downloading resources.

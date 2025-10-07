# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A multilingual personal blog built with Astro 5, based on the AstroPaper theme with full i18n support. The blog supports Arabic (RTL) and English (LTR) locales with separate content directories for each language.

## Development Commands

```bash
# Development
pnpm dev                 # Start dev server at localhost:4321
pnpm build              # Build production site + generate Pagefind search index
pnpm preview            # Preview production build locally
pnpm sync               # Generate TypeScript types for Astro modules

# Code Quality
pnpm format             # Format code with Prettier
pnpm format:check       # Check code formatting
pnpm lint               # Lint code with ESLint

# Testing
pnpm test               # Run unit tests with Vitest
pnpm test:watch         # Run tests in watch mode
pnpm coverage           # Generate test coverage report
```

## Deployment

The blog deploys to AWS (CloudFront + S3 + Route53) using SAM. See [DEPLOYMENT.md](DEPLOYMENT.md) for details.

```bash
./scripts/deploy.sh     # Build + deploy to AWS
```

## Architecture

### Internationalization (i18n)

**Core i18n Files:**
- [src/i18n/config.ts](src/i18n/config.ts) - Locale configuration with `localeToProfile` mapping
- [src/i18n/locales/](src/i18n/locales/) - Translation files (ar.ts, en.ts)

**LocaleProfile Structure:**
- `name` - Display name in language picker
- `messages` - Translation strings object
- `langTag` - IANA language tag (e.g., "ar-SY", "en-US") for date/number localization and sitemap
- `direction` - UI layout direction ("rtl" or "ltr")
- `googleFontName` - Font for OG image generation (must support 400/700 weights)
- `displayName` - Alternative display name
- `default` - Boolean flag to mark default locale

**Adding a New Locale:**
1. Create translation file in [src/i18n/locales/\<locale\>.ts](src/i18n/locales/)
2. Add locale entry to `localeToProfile` in [src/i18n/config.ts](src/i18n/config.ts)
3. Create content directory [src/data/blog/\<locale\>/](src/data/blog/)
4. Create about page [src/data/about/about.\<locale\>.md](src/data/about/)

### Content Collections

Defined in [src/content.config.ts](src/content.config.ts) using Astro's file loaders:

**Blog Collection:**
- Location: [src/data/blog/\<locale\>/](src/data/blog/) (organized by locale subdirectories)
- Pattern: `**/[^_]*.md` (excludes files starting with `_`)
- Locale extracted from file path structure

**About Collection:**
- Location: [src/data/about/](src/data/about/)
- Naming: `about.<locale>.md` (e.g., about.en.md, about.ar.md)

**Blog Post Frontmatter:**
```yaml
title: string
author: string (defaults to SITE.author)
pubDatetime: date (required)
modDatetime: date (optional)
description: string (required)
tags: string[] (defaults to ["others"])
featured: boolean (optional)
draft: boolean (optional)
ogImage: image or string (optional)
canonicalURL: string (optional)
hideEditPost: boolean (optional)
timezone: string (optional, overrides global SITE.timezone)
```

### Routing Structure

All pages use `[...locale]` dynamic routing pattern for i18n:
- `/[...locale]/` - Homepage
- `/[...locale]/posts/[...page]` - Paginated post list
- `/[...locale]/posts/[...slug]/` - Individual post
- `/[...locale]/tags/` - All tags
- `/[...locale]/tags/[tag]/[...page]` - Posts by tag
- `/[...locale]/archives/` - All posts archive
- `/[...locale]/about` - About page
- `/[...locale]/search` - Search page (uses Pagefind)

### Post Utilities

Key utilities in [src/utils/](src/utils/):

- **posts.ts** - Core post retrieval functions:
  - `getPosts()` - Retrieve all posts with filtering
  - `getPostsByLocale()` - Get posts for specific locale
  - `getPostsGroupedByLocale()` - Group posts by locale
  - `groupPostsByLocale()` - Helper to organize posts by locale

- **getSortedPosts.ts** - Sort posts by date (considers timezone and scheduled post margin)
- **postFilter.ts** - Filter logic for published vs draft posts
- **getPostsByTag.ts** - Filter posts by tag
- **slugify.ts** - Convert strings to URL-safe slugs

### Configuration

**[src/config.ts](src/config.ts) - Global site config:**
```typescript
SITE.website         // Deployed domain
SITE.author          // Default author name
SITE.postPerIndex    // Posts per index page
SITE.postPerPage     // Posts per pagination page
SITE.timezone        // Global timezone (IANA format)
SITE.editPost        // Edit post URL configuration
SITE.showArchives    // Show/hide archives page
SITE.dynamicOgImage  // Enable dynamic OG image generation
```

**[astro.config.ts](astro.config.ts) - Astro configuration:**
- Sitemap integration with i18n support
- Remark plugins: `remark-toc` (supports Arabic TOC headings), `remark-collapse`
- Tailwind CSS 4 via Vite plugin
- Shiki syntax highlighting (light: min-light, dark: night-owl)

## Important Notes

### Locale Extraction
Posts and about pages determine their locale from file path structure:
- Blog: `src/data/blog/<locale>/*.md`
- About: `src/data/about/about.<locale>.md`

Locale keys in [src/i18n/config.ts](src/i18n/config.ts) must be lowercase to match directory names.

### Build Process
The build command chains multiple steps:
```bash
astro build && pagefind --site dist && cp -r dist/pagefind public/
```
This builds the site, generates the search index, and copies it to public directory.

### RTL Support
Arabic locale uses RTL direction. Layout components handle bidirectional text automatically via the `direction` property in locale profiles.

### Timezone Handling
Posts can override the global `SITE.timezone` with a frontmatter `timezone` field. This affects scheduled post visibility (determined by `scheduledPostMargin`).

### Git Commits
This repository uses Commitizen for conventional commits. Husky pre-commit hooks enforce code quality checks.

## Translation Terminology (English → Arabic)

When translating technical content from English to Arabic, use the following standardized terminology:

**Important:** Always include the English technical term in parentheses after the Arabic translation on first occurrence in each section/paragraph.

### Arabic Sentence Structure

**Use VSO (Verb-Subject-Object) ordering whenever possible** instead of SVO (Subject-Verb-Object). This is the natural and preferred sentence structure in formal Arabic writing.

Examples:
- ✅ VSO: `تعمل النماذج اللغوية الضخمة بشكل مختلف` (Work the LLMs differently)
- ❌ SVO: `النماذج اللغوية الضخمة تعمل بشكل مختلف` (The LLMs work differently)

- ✅ VSO: `يخلق هذا تحديات أمنية` (Creates this security challenges)
- ❌ SVO: `هذا يخلق تحديات أمنية` (This creates security challenges)

### Terminology Table

| English | Arabic (with English in parentheses) |
|---------|--------|
| Large Language Models (LLM) | النماذج اللغوية الضخمة (Large Language Models) |
| Attack Vector | نوع هجوم (Attack Vector) [singular], أنواع هجوم (Attack Vectors) [plural] |
| Rate Limiting | ضبط سرعة الطلبات (Rate Limiting) |
| Fine tuning | معايرة (Fine-tuning) |
| Threat landscape | وضع أمني (Threat Landscape) |
| Membership inference attack | هجوم استنباط بيانات التدريب (Membership Inference Attack) |
| Training pipeline | مسار التدريب (Training Pipeline) [singular], مسارات التدريب (Training Pipelines) [plural] |
| Buffer overflow attack | هجوم تطفيف الذاكرة (Buffer Overflow Attack) |
| Agreeable | متساوق (Agreeable) [masculine], متساوقة [feminine] |
| Denial of wallet | استنفاذ المحفظة (Denial of Wallet) |
| Prompt injection | حقن الأوامر (Prompt Injection) |
| Contextual separation | فصل السياق (Contextual Separation) |
| Hardened prompting | تعزيز الأوامر (Hardened Prompting) |
| Output monitoring | مراقبة المخرجات (Output Monitoring) |
| Continuous adversarial testing | اختبار مستمر للخصوم (Continuous Adversarial Testing) |
| Probabilistic reasoning | الاستدلال الاحتمالي (Probabilistic Reasoning) |
| Data poisoning | تسميم البيانات (Data Poisoning) |
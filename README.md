# Muaz Othman's Blog

A personal blog built with [AstroPaper](https://github.com/satnaing/astro-paper) theme with i18n support.

[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

## 🚀 Features

- **Type-safe and Fast:** Built with [Astro](https://astro.build/) and TypeScript
- **SEO Friendly:** Sitemap, RSS feeds, and Open Graph image generation
- **Internationalization:** Full i18n support with RTL language compatibility
- **Accessible:** WCAG-compliant color contrast and keyboard navigation
- **Responsive:** Mobile-first design with dark/light mode
- **Full-text Search:** Powered by [Pagefind](https://pagefind.app/)
- **Conventional Commits:** Using Commitizen for standardized commits

## 📦 Tech Stack

- **Framework:** Astro 5
- **Styling:** Tailwind CSS 4
- **Content:** Markdown with Remark plugins
- **Search:** Pagefind
- **Testing:** Vitest
- **Code Quality:** ESLint, Prettier, Husky
- **Deployment:** AWS SAM (CloudFront, S3, Route53)
- **CI/CD:** GitHub Actions

## 🛠️ Installation

```bash
# Clone the repository
git clone https://github.com/MuazOthman/blog.muazothman.com.git

# Install dependencies
pnpm install
```

## 🧞 Commands

| Command             | Action                                          |
| :------------------ | :---------------------------------------------- |
| `pnpm dev`          | Start local dev server at `localhost:4321`      |
| `pnpm build`        | Build production site and generate search index |
| `pnpm preview`      | Preview your build locally before deploying     |
| `pnpm sync`         | Generate TypeScript types for Astro modules     |
| `pnpm format`       | Format code with Prettier                       |
| `pnpm format:check` | Check code formatting                           |
| `pnpm lint`         | Lint code with ESLint                           |
| `pnpm test`         | Run unit tests                                  |
| `pnpm test:watch`   | Run unit tests in watch mode                    |
| `pnpm coverage`     | Generate test coverage report                   |

## 🚀 Deployment

The blog is deployed to AWS using SAM (Serverless Application Model). For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

### Quick Deploy

```bash
# Set your ACM certificate ARN
export CERTIFICATE_ARN=your-certificate-arn

# Deploy
./scripts/deploy.sh
```

## 📝 Adding Content

### Blog Posts

Create markdown files in [src/data/blog/\<locale\>/](src/data/blog/) directory:

```markdown
---
title: "Your Post Title"
description: "Post description"
pubDatetime: 2024-01-01T00:00:00Z
tags: ["tag1", "tag2"]
---

Your content here...
```

### About Page

Edit the about page in [src/data/about/](src/data/about/) for each locale:

```markdown
---
title: "About"
description: "About page description"
---

Your about content...
```

## 🌐 Internationalization

This blog supports multiple languages. To add a new locale:

1. Create translations file in [src/i18n/locales/](src/i18n/locales/)
2. Configure locale in [src/i18n/config.ts](src/i18n/config.ts)
3. Add content in [src/data/blog/\<locale\>/](src/data/blog/)
4. Add about page in [src/data/about/about.\<locale\>.md](src/data/about/)

## ⚙️ Configuration

Edit [src/config.ts](src/config.ts) to customize:

- Site metadata
- Author information
- Posts per page
- Timezone
- Edit post URL
- And more...

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- [AstroPaper](https://github.com/satnaing/astro-paper) - Original theme
- [AstroPaper I18n](https://github.com/yousef8/astro-paper-i18n) - I18n support fork

---

Built with ❤️ by [Muaz Othman](https://github.com/MuazOthman)

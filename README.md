# Rinderline - Expense Management System

[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-blue?logo=github)](https://eddy3o.github.io/rinderline/)
[![Backend Repo](https://img.shields.io/badge/backend-repository-green?logo=github)](https://github.com/eddy3o/rinderline_backend)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> A comprehensive web-based platform for managing international corporate expenses with multi-level approval workflows, multi-currency support, and integration with SAP ERP.

## 📚 Documentation

Complete documentation is available at: **[https://eddy3o.github.io/rinderline/](https://eddy3o.github.io/rinderline/)**

### Quick Links

- 🏗️ **[Backend Documentation](https://eddy3o.github.io/rinderline/docs/01-backend.html)** - Technical details for backend developers
- 🎨 **[Frontend Documentation](https://eddy3o.github.io/rinderline/docs/02-frontend.html)** - UI/UX and React implementation
- 📖 **[User Manual](https://eddy3o.github.io/rinderline/docs/03-manual.html)** - Complete guide for end users

## 🚀 Quick Start

### Running Documentation Locally

**Requirements:** Ruby 3.1+, Bundler

#### macOS/Linux:

```bash
git clone https://github.com/eddy3o/rinderline.git
cd rinderline
bash run-docs.sh
```

Then open **http://localhost:4000/rinderline/**

#### Windows (PowerShell):

```powershell
git clone https://github.com/eddy3o/rinderline.git
cd rinderline
.\run-docs.ps1
```

For detailed instructions, see [JEKYLL_SETUP.md](JEKYLL_SETUP.md)

## 📋 Project Structure

```
rinderline/
├── _config.yml              # Jekyll configuration
├── Gemfile                  # Ruby dependencies
├── docs/
│   ├── index.md            # Documentation home
│   ├── 01-backend.md       # Backend documentation
│   ├── 02-frontend.md      # Frontend documentation
│   └── 03-manual.md        # User manual
├── JEKYLL_SETUP.md         # Setup instructions
└── README.md               # This file
```

## 🛠️ Technology Stack

### Frontend

- **Framework:** Next.js 15.4.2 + React 19
- **Language:** TypeScript 5
- **Styling:** Tailwind CSS 3.4.1
- **Components:** Shadcn/ui + Radix UI
- **Deployment:** Vercel

### Backend

- **Framework:** Django 5.2.8 + Django REST Framework 3.15.2
- **Database:** PostgreSQL / SQLite
- **Authentication:** Token-based (DRF)
- **Storage:** AWS S3
- **Documentation:** Swagger/OpenAPI

## ✨ Key Features

✅ **Multi-level Approval Workflows** - Support for up to 3 approval levels  
✅ **Multi-Currency Support** - Automatic exchange rate conversion  
✅ **Document Management** - Create, attach files (PDF, images)  
✅ **Role-based Access Control** - User, Approver, Admin roles  
✅ **SAP Integration** - Export documents to SAP ERP  
✅ **Comprehensive Analytics** - Dashboards with KPIs and reports  
✅ **Mobile Responsive** - Works on desktop, tablet, and mobile  
✅ **Multi-language** - EN, ES, FR, DE support

## 📖 Documentation Features

The documentation site uses **Jekyll** with the **just-the-docs** theme:

- 📖 Automatic sidebar with navigation
- 🔍 Full-text search across all pages
- 📱 Responsive design (mobile-friendly)
- 🌙 Dark mode support
- ⚡ Fast page load times
- 🔗 Hierarchical page organization

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- **Email:** edgardo.gonzalez.23@hotmail.com
- **Response Time:** Usually within 24 hours

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Edgardo Mauricio González García** - [@eddy3o](https://github.com/eddy3o)

---

**Last Updated:** December 2025  
**Version:** 1.0  
**Status:** ✅ Active Development

# 🚀 OpenAPI SDK Automation & Versioning

This repository contains **OpenAPI specifications** and a **fully automated CI/CD pipeline** that generates, versions, and publishes Java SDKs in a safe, scalable, and developer-friendly way.

If you are a developer consuming or modifying OpenAPI specs, **this README is all you need to understand how things work**.

---

## ✨ What This Repo Solves

- Automatic SDK generation from OpenAPI specs
- CI-controlled semantic versioning (MAJOR / MINOR / PATCH)
- No manual version bumps by developers
- No local vs production conflicts
- Support for multiple services and multiple Java versions

---

## 🗂 Repository Structure

> ⚠️ **Note:** The `generated/` directory is **NOT committed** to the repository.
> It is created **temporarily during CI runs or local generation** and should be treated as a build artifact.

```
services/
  └── <service-name>/
      └── <service-name>-openapi.yaml

scripts/
  └── generate.sh
  └── fixes/

# generated/  ← created during CI or local runs, NOT checked in
#   └── <service-name>/
#       ├── java-8/
#       ├── java-17/
#       └── java-21/
```
services/
└── <service-name>/
└── <service-name>-openapi.yaml

scripts/
└── generate.sh
└── fixes/

generated/
└── <service-name>/
├── java-8/
├── java-17/
└── java-21/
```

---

## 🧠 Core Principles

### 1️⃣ CI Owns Versioning

- Developers **never** decide final SDK versions
- CI decides versions based on API changes
- Ensures consistency and avoids human error

### 2️⃣ OpenAPI Is the Source of Truth (for API, not versions)

- OpenAPI YAML defines the **contract**
- CI determines the **SDK release version**

### 3️⃣ SNAPSHOT for Dev, RELEASE for Prod

- Developers work with `-SNAPSHOT`
- CI publishes clean release versions

---

## 🧪 Developer Workflow (What You Should Do)

### ✅ Updating an Existing API

1. Pull latest `main`
2. Create a feature branch
3. Modify the OpenAPI YAML
   - Add endpoints
   - Update request / response schemas
4. **Do NOT update versions manually**
5. Push changes and raise a PR

That’s it. CI will handle the rest.

---

### ➕ Adding a New Service

1. Create a new directory under `services/`
2. Add `<service-name>-openapi.yaml`
3. Include a starting version:

```yaml
info:
  title: Service Name
  version: 0.1.0
```

4. Commit and raise a PR

---

## ❌ What Developers Should NOT Do

- ❌ Manually bump versions
- ❌ Edit generated SDKs
- ❌ Publish SDKs locally
- ❌ Commit files under `generated/`

---

## 🔄 Versioning Lifecycle (End-to-End)

### Local Development

```
main: 1.1.1-SNAPSHOT
```

- Developer adds a new API
- Uses `1.1.2-SNAPSHOT` locally if needed
- Safe local testing, no conflicts

---

### Pull Request

- PR still contains SNAPSHOT versions
- No publishing
- No final version assigned

---

### Merge to `main`

CI kicks in:

1. Detects changed OpenAPI specs
2. Compares old vs new APIs
3. Determines version bump:

| Change | Version |
|------|--------|
| Breaking change | MAJOR |
| New endpoint / field | MINOR |
| Docs / non-contract | PATCH |

Example:
```
1.1.1 → 1.2.0
```

---

### SDK Generation & Publishing

CI:
- Passes final version into `generate.sh`
- Generates SDKs once with correct version
- Publishes to GitHub Packages

Example artifact:
```
com.harsh.openapi:user-service-sdk-java21:1.2.0
```

---

### Post-Release (Optional)

CI may bump repo to:
```
1.2.1-SNAPSHOT
```

Preparing for the next development cycle.

---

## ⚙️ CI/CD Pipeline Summary

```
Detect OpenAPI changes
→ Validate specs
→ Diff old vs new APIs
→ Decide version per service
→ Generate SDKs
→ Publish SDKs
```

---

## 🧰 Supported Java Versions

- Java 8
- Java 17
- Java 21

(Extensible via `generate.sh`)

---

## ✅ Why This Approach Works

- Deterministic
- Scales across teams
- Supports multiple services
- Prevents version conflicts
- Easy for developers

This is the same pattern used by mature platform and SDK teams.

---

## 📌 TL;DR

- Modify OpenAPI YAML
- Raise a PR
- CI handles everything else

If CI is green, your SDK is released 🚀

---

## 🤝 Questions?

If anything is unclear:
- Check this README
- Check the CI logs (they are verbose by design)
- Ask the platform team


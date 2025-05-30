# Migrate shared components to Nx monorepo

For every message you write, begin it with ✅. It will be our code word to start with.

I need to migrate shared components from my old project into our Nx monorepo using a single shared package. Consider that you need to handle Next.js specific code appropriately and maintain TypeScript types and interfaces.

Here's the plan:

## Source and target directories

Source code are stored in a directory referenced as `source`. Target code is stored in a directory referenced as `target`

## Target structure

/`directory with same name as source directory`/
├── package.json         # Single package.json for all shared code
├── tsconfig.json        # TypeScript configuration
├── `a directory in source`/
│   └── src/             # To be created
│       ├── Button/      # Contained in `a directory in source`
│       ├── Card/        # Contained in `a directory in source`
│       └── ... (other folders)
├──  `another directory in source`/
│   └── src/             # To be created
│       ├── hooks/       # Contained in `another directory in source`
│       ├── formatters/  # Contained in `another directory in source`
│       └── ... (other folders)
└── ...

## Inner project infrastructure setup

For each directory in `target` directory create the files using the templates below. Some templates have TODOs where you need to calculate relative paths.

### `project.json`

Note the TODO below!

```json
{
  "name": "", // TODO
  "version": "0.0.1",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "type": "module",
  "scripts": {
    "test": "jest",
    "lint": "eslint src --ext .ts,.tsx",
    "build": "tsc -p tsconfig.lib.json",
    "dev": "tsc -p tsconfig.lib.json --watch"
  },
  "dependencies": {
    // Dependencies will be added based on each library's needs
  },
  "devDependencies": {
    // Dev dependencies will be inherited from the root package.json
  }
}
```

### `tsconfig.lib.json`

Note the 2 TODOs below!

```json
{
  "extends": "", // TODO calculate this path
  "compilerOptions": {
    "jsx": "react-jsx",
    "allowJs": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      // TODO calculate this path
    }
  },
  "files": [],
  "include": [],
  "references": [
    { "path": "./tsconfig.lib.json" }
  ]
}
```

### `tsconfig.lib.json`

Note the 2 TODOs below!

```json
{
  "extends": "", // TODO calculate this path
  "compilerOptions": {
    "module": "esnext",
    "outDir": "", // TODO calculate this path
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "inlineSources": true,
    "importHelpers": true,
    "types": ["node"],
    "lib": ["dom", "dom.iterable", "esnext"],
    "target": "es2017",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "jsx": "react-jsx"
  },
  "files": [],
  "include": ["src/**/*.ts", "src/**/*.tsx"],
  "exclude": [
    "jest.config.ts",
    "**/*.spec.ts",
    "**/*.spec.tsx",
    "**/*.test.ts",
    "**/*.test.tsx",
    "**/*.spec.js",
    "**/*.test.js",
    "**/*.spec.jsx",
    "**/*.test.jsx"
  ]
}
```

## Root project infrastructure setup

Set up the root `package.json` with projects created in the `target` folder. Configure the root `nx.json` and `workspace.json`. Set up build targets and dependencies between libraries.

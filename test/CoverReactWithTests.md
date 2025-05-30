# Cover React componets with tests

We will be covering a React project with snapshot tests. For each component in the given directory, we need to create a test file and cover all the possible states of the component.

- First cover with tests one component, run the new test to be sure that the test is working.
- Then cover with test all of the other components and run tests to be sure that all tests are working.

## Directory structure

Let's consider this as the input directory:

```
Add/
└── components/
    ├── LinkToVideo/
    │   ├── LinkToVideoMobile.tsx
    │   ├── LinkToVideoScreenMobile.tsx
    │   └── index.ts
    │
    ├── SelectCarCategoryScreen/
    │   ├── SelectCarCategoryScreenMobile.tsx
    │   └── index.ts
    │
    ├── SpecificationsOfCar/
    │   └── SpecificationsOfCarMobile.tsx
    │
    └── UploadPhoto/
        ├── UploadPhotoMobile.tsx
        └── style.css
```

I expect the final directory structure to look like this:

```
Add/
└── components/
    ├── LinkToVideo/
    │   ├── LinkToVideoMobile.tsx
    │   ├── LinkToVideoScreenMobile.tsx
    │   └── index.ts
    │
    ├── SelectCarCategoryScreen/
    │   ├── SelectCarCategoryScreenMobile.tsx
    │   └── index.ts
    │
    ├── SpecificationsOfCar/
    │   └── SpecificationsOfCarMobile.tsx
    │
    ├── UploadPhoto/
    │    ├── UploadPhotoMobile.tsx
    │    └── style.css
    │
    └── __tests__/
        ├── __snapshots__/
        │   ├── LinkToVideoMobile.test.tsx.snap
        │   ├── SelectCarCategoryScreenMobile.test.tsx.snap
        │   ├── SpecificationsOfCarMobile.test.tsx.snap
        │   └── UploadPhotoMobile.test.tsx.snap
        │
        ├── LinkToVideoMobile.test.tsx
        ├── SelectCarCategoryScreenMobile.test.tsx
        ├── SpecificationsOfCarMobile.test.tsx
        └── UploadPhotoMobile.test.tsx
```

## Component test file

Each test file should look like this:

```typescript
// imports

describe('<ComponentName> snapshot tests', () => {
    it('should match the snapshot', () => {
        testSnapshot(<ComponentName />);
    });
});
```

## Test utils

Try to find `testSnapshot` function in `testUtils.tsx` file in the project and if present, use it for tests. If it is not found, define it in a `testUtils.tsx` file, look for an appropriate location. It should look like this:

```typescript
import React, { ReactElement } from 'react';
import { render } from '@testing-library/react';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';

const renderWithReduxStore = (
  ui: ReactElement,
  {
    preloadedState = {},
    store = configureStore({
      reducer: {},
      middleware: (getDefaultMiddleware) => getDefaultMiddleware(),
    }),
    ...renderOptions
  } = {}
) => {
  const Wrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Provider store={store}>{children}</Provider>
  );

  return render(ui, { wrapper: Wrapper, ...renderOptions });
};

export const testSnapshot = (Component: React.ReactElement) => {
  const { container } = renderWithReduxStore(Component);
  expect(container).toMatchSnapshot();
};
```

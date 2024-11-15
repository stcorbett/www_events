Analyze the following code from a Rails application, which includes the `{controller}` controller, its associated views, routes, and any relevant CSS:

```
{context}
```

Your task is to:
1. **Identify All Routes**: Parse the provided code, especially focusing on the `config/routes.rb` file to identify all routes related to the `{controller}` controller. This includes standard CRUD routes (`index`, `show`, `new`, `create`, `edit`, `update`, `destroy`), as well as any custom routes (e.g., `diff`, `history`, `toggleannotations`).
2. **Generate Tests for Each Route**: Break down each route into the necessary user interface interactions, such as form submissions for POST routes, link clicks for GET routes, and handling confirmation dialogs for DELETE routes.
3. **UI Element Interaction**: Identify the specific UI elements (e.g., buttons, forms, links) associated with these routes, including hover-triggered elements, confirmation dialogs, and dynamic selectors.  Prefer cypress-real-events such as `cy.realHover()` and `cy.realClick()` to interact with the page.
4. **Login Requirements**: The application requires a login with the following credentials:
   - **Username**: `admin`
   - **Password**: `admin123`
   The login page is located at `http://localhost:3000/login`. Each test should begin with logging into the application.
5. **Generate Full Cypress Test Suite**: Write a complete Cypress test suite in JavaScript that covers:
   - **CRUD Operations**: Tests for Create, Read, Update, and Delete actions for `{controller}` resources.
   - **All Associated Routes**: Write tests for any custom routes linked to the `{controller}` controller, including actions like viewing history, comparing diffs, or toggling annotations.

The final output should be JavaScript code that contains:
- **Dynamic Tests for All Routes**: Write Cypress tests for each route associated with the `{controller}` controller, ensuring the use of dynamic selectors (avoid hardcoding element IDs). Handle special UI interactions, such as hover effects (`realHover()`), confirmation dialogs, and form submissions.
- **Comprehensive CRUD Testing**: Include tests for full CRUD functionality, with appropriate assertions for successful outcomes and edge cases (e.g., validation errors).
- **Custom Route Tests**: Write specific tests for non-CRUD routes defined in the `{controller}`, such as routes for history, annotations, or diff comparison.
- **Login Flow**: Each test should start by visiting the login page at `http://localhost:3000/login`, filling in the credentials (`admin`/`admin123`), and submitting the form to authenticate.
- **Base URL**: The application is running at `http://localhost:3000`, so all route-related tests should use this base URL for navigation.
- **Modular Structure**: Organize the tests into reusable and modular blocks, using Cypress `beforeEach` to set up reusable functionality (like logging in) and reduce code repetition.
- **Test Independence**: Ensure that each test is independent and does not rely on the state of other tests.  Each test case should create its own data in a `beforeEach` function.  When creating data use `cy.visit` instead of `cy.request`.
- **Error Handling and Assertions**: Include detailed assertions for successful interactions, handling error conditions where applicable.

The final output should be a complete JavaScript file containing all Cypress tests for the `{controller}` controller and its associated routes, ready to be executed within a Cypress test suite.
Output code only with no explanations.

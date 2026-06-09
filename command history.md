
to the camps table
add a year column - integer
    then run a migration
    set this column for each camp based on the record's 'created_at'

in the Camp model
    validates :name, uniqueness: true, presence: true
    should be scoped to the new year column

    write a spec that shows I can use the same name twice but for different years

on https://whatwherewhen.lakesoffire.org/admin/camps
    add a horizontal nav at the top of the list of camps
    the first tab should say "this year"
    and following that, there should be a list of previous years for which we have camps
    sort the camps into years by their year

on the main page (event creation form)
    for the Where section, and the Who section
    if I am using the autocomplete for a camp name
        the data set being used should only be camps with this year's year column

    write a spec that tries to use a previous year camp in this interface







add a "Log in with Email" button next to "Log in with Google" on the /login page

clicking this button takes you to a new page with the same layout and basic card structure but with an explanation of logging in with email
and an input box for folks to type their email addresses
and a button for "Send login Email" and a button for "Create Account"

submitting that input/form/button checks to see if you have an account
if you do, it takes you to a page with the same layout that says "Click the link in your email to log in"
And sends an email to the account with an authentication link.

if you don't have an account already, it takes you to the login/create account page and shows an error message about the account not being found

Clicking the authentication link from your email brings the user back to the app, but they are authenticated as that email addresses

Clicking the "Create Account" button on the login/create account page creates a new account and sends an email to the account with an authentication link
It redirects you to the "Click the link in your email to log in" page

If someone clicks an authentication link that is invalid, take them to the login/create account page and show an error message






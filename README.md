# OpenGraphPreviewer
This application cleverly coined "Open Graph Previewer" is meant to consume an external URL, process it, and then
display its og:image on the front end.

## Setup
To start your Phoenix server and pull in updates:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Implementation Steps
I approached this implementation by breaking down the entire process into smaller, manageable steps. 
Let me walk you through how I tackled each of these steps. But first here is the process in a TLDR; bit:

In a nutshell, the process is:
- URL passes through the form to PageController
- If the URL is valid, check DB, if it isn't present, add it to DB with the status of "processing"
- Hits an async task and performs a GET request via HTTPoison
- og:image data parsed via Floki
- Redirected to /url/#{url}
- JS (Axios) hits poll_status function until the URL's DB status is updated to "done"

## Step 1 - Data table migration and Ecto Schema
I always find it best to create the DB structure before doing anything else. In this case, I created a "Url"
table to hold the URL being passed in, the og:image, and the processing status which will be either "processing" or "done".

## Step 2 - Front-end form, Controller actions, and routes
Next, I crafted a simple form right on the homepage (app.html.heex). Users can enter a URL, and that input would be passed to the PageController which will hit the "submit" function and send the data to processing

## Step 3 - Validate URL, GET request(s), HTML body parsing and image returned to front-end
Moving forward, I tapped into the power of external packages. I used HTTPoison to make the GET request for fetching URL data. 
Then, I turned to Floki, a personal favorite, to dig into the HTML body and extract the 'og:image' content attribute.

I added some edge case logic during this setup as well. If the URL returns a 301, we want to get that redirected URL and use that
as the new URL source to get the og:image. Recursion worked out well for this.

All of this gets skipped if the URL doesn't pass the RegEx I put in place to validate the URL string.

Finally, it redirects to /url/ while the async process is running

## Step 4 - DB insertions and asynchronous setup
Then I bundled up the bulk of the processing within a Task.async(), which is Elixir's way of handling asynchronous tasks. 
Before and during this, I add the logic to insert the URL into the DB with a status of "processing" and during the Task.async()

I think given more time, I would have likely discarded the DB entirely and utilized ErLang's built-in caching called ETS (ErLang Term Storage). 
I could have then used an external library called "Eternal" that gets loaded in the Supervisor to persist the caching's longevity and modify the JS 
to check the status of the image in there.

## Step 5 - JS refreshing
Lastly, there is some Axios JS added to the homepage to check the status of the URL and returns it if found otherwise
shows a missing image. To avoid endless calls, I capped the polling at 5 times with 500ms between each one.

## Manual testing done
- URL missing protocol and/or subdomain
- URL returning 301 redirects to a different URL
- Unsafe characters
- Non-URL input
- Duplicate entries don't create new DB rows

## Automated testing done
- Added a few controller level tests to ensure general stability

## Notes
If more time was allotted, I would have...

- moved a lot of the controller logic into a context file to separate it and keep the controller clean.
  I figured it'd be easier to read/assess in one file
- written more automated tests!
- Focus on a bug where very few specific URLs i.e. https://www.linkedin.com returns no og:image,
  but upon clearing the DB row and trying again it works
  - Lastly, add more JS to change "Check Website" to "Checking..." while it's processing to let the user know whats going on

Thank you for taking the time to read my application!
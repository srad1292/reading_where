# 1. MVP

## B. State List

[] - Data: Get state flag images
[] - Data: Create list of states along with their abbreviations and country code
- Multiple: Add stateCode to book class and example instance
- State List: State list display which should match country just without region grouping
- State List: Update header when state list to show read/total states
- Book information: When type is state or book contains stateName country can just show US or be hidden
- Book information: When type is state or book contains stateCode show states dropdown

## C. Persistence 

- Database setup 
- Add countries to database on initial setup
- Add US states to database on initial setup
- Add existing book information to database on initial setup
- Book List: get country and book information from DB
- Book Information: If db book has image, show, otherwise get from API 
- Book Information: If saving and image not already in db book, save image as well
- Book Information: Saving should add/update/delete within DB as well

## D. Book Search

- Pagination

# 2. Make it nice

- Font styling, colors, etc
- Flag image caching for improved speed on page
- Flag images: something to help the white parts of flag not being lost to background?
- Book List: Show authors/date?
- Book Information: Update rating input to different type

# 3. Book List Filter

- Book List Filter: Create Page
- Book List: When pop from filter page, use filter to update display

# 4. Analytics

- Figure out what data I want to track and how I want to display it
- Author gender
- Fiction vs nonfiction
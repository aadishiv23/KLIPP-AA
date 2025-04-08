# shiny/apps/AA_viewer/modules/viewAA/viewAA_server.R

# Define the server logic for the viewAA module
viewAAServer <- function(id, ...) {
    moduleServer(id, function(input, output, session) {
#----------------------------------------------------------------------
# Section: Reactives and Setup
#----------------------------------------------------------------------
# Access the parent session variables (e.g., uploaded data)
# Use ... to pass these down if needed, or retrieve from a shared reactive state
app <- get("app", parent.env(environment())) # Standard way to get app session data

# Placeholder reactive to store the loaded classification data
classificationData <- reactiveVal(NULL)

# Placeholder reactive to store path to the SV plot image
svPlotPath <- reactiveVal(NULL)

#----------------------------------------------------------------------
# Section: Observers and Event Handlers
#----------------------------------------------------------------------
# Example: Observer to load data when the app step becomes active
# (We'll need to refine this based on how data is passed between steps)
# Load data once the uploaded package is ready
observe({
    # Access the uploaded data package reactive Wraper
    # It triggers reactivity when the package is uploaded or changed.
    package <- app$data$package$value # Get the package object from the reactive wrapper

    # Req requires that the package is not NULL (i.e., has been uploaded)
    req(package) 

    # Find and load the classification table file using the key from config.yml
    # getPath() finds the *one* file matching the 'classification_results_table' type
    tablePath <- package$getPath("classification_results_table") 
    
    # Req requires that the path was found and the file exists
    req(tablePath, file.exists(tablePath)) 
    
    # Load the data (using data.table::fread for efficiency with TSV)
    # Add error handling for robustness
    loadedData <- tryCatch({
         data.table::fread(tablePath)
    }, error = function(e) {
         # Handle error, e.g., show a notification to the user
         showNotification(
             paste("Error loading classification table:", e$message), 
             type = "error", 
             duration = NULL
         )
         NULL # Return NULL if loading failed
    })
    
    # Req requires that loading was successful
    req(loadedData) 
    
    # Store the loaded data in the reactiveVal
    classificationData(loadedData) 
    
    # --- Load the SV Plot Image Path (Example for Amplicon 1) ---
    # findFiles() finds potentially *multiple* files matching the 'aa_sv_png' type
    # We need logic to select the correct one (e.g., for amplicon 1 first)
    svPlotPaths <- package$findFiles("aa_sv_png")
    req(svPlotPaths) # Require that some PNG files were found

    # Simple logic: find the one ending in 'amplicon1.png'
    # More complex logic might be needed if numbering isn't guaranteed
    amplicon1PlotPath <- NULL
    for(filePath in svPlotPaths){
        if(grepl("_amplicon1\\.png$", filePath$path)){ # Check if path ends with _amplicon1.png
             amplicon1PlotPath <- filePath$path
             break # Stop after finding the first match
        }
    }

    # If we found amplicon 1's plot, store its path
    if (!is.null(amplicon1PlotPath) && file.exists(amplicon1PlotPath)) {
        svPlotPath(amplicon1PlotPath)
    } else {
         # Handle case where amplicon 1 plot wasn't found (optional)
         showNotification("Amplicon 1 SV plot (.png) not found in package.", type = "warning")
         svPlotPath(NULL) # Clear any previous path
    }

}) # End observe block

#----------------------------------------------------------------------
# Section: Render UI Elements
#----------------------------------------------------------------------
# Render the classification data table
output$classificationTable <- DT::renderDataTable({
    req(classificationData()) # Require data to be loaded
    
    DT::datatable(
         classificationData(),
         rownames = FALSE,
         class = "display compact",
         filter = 'top',
         options = list(
             pageLength = 10,
             scrollX = TRUE
             # Add other DT options if desired
         )
    )
})

# Render the SV plot image
output$svPlotImage <- renderImage({
    req(svPlotPath()) # Require the path to the image
    
    list(
        src = svPlotPath(),
        contentType = 'image/png',
        # Adjust width/height as needed
        # width = 800, 
        # height = 600,
        alt = "Amplicon SV Plot"
    )
}, deleteFile = FALSE) # Important: Don't delete the source file

#----------------------------------------------------------------------
# Section: Module Return Value
#----------------------------------------------------------------------
# Define values/reactives to return to the parent server module (if needed)
# Typically used for passing results to subsequent steps or saving bookmarks
list(
    # myValue = reactive( ... ), # Example
    # myMethod = function(...) { ... } # Example
)
#----------------------------------------------------------------------
}) # End moduleServer call
}
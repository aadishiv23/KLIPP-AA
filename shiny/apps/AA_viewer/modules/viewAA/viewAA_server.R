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
# observe({
#     # Check if data is ready from previous step (e.g., sourceFileUpload)
#     # req(app$data$package$upload()) # Requires data package to be uploaded
#     
#     # Find and load the classification table file
#     # tablePath <- app$data$package$getPath("classification_results_table") 
#     # req(file.exists(tablePath))
#     # loadedData <- data.table::fread(tablePath)
#     # classificationData(loadedData)
#     
#     # Find the path to the SV plot PNG (assuming amplicon 1 for now)
#     # Need logic here to select the correct amplicon based on user input or defaults
#     # plotPaths <- app$data$package$findFiles("aa_sv_png", filter = "_amplicon1.png") 
#     # if(length(plotPaths) > 0) svPlotPath(plotPaths[[1]]$path)
# })

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
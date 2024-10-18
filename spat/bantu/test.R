library(openxlsx)
library(sf)
# library(geojsonio)

# Define the file path
file_path <- "C:/Users/Thomas Huet/Desktop/temp/Book1.xlsx"

# Read the specific columns (F and H) from the first row in the 'MAIN' sheet
df <- openxlsx::read.xlsx(file_path, sheet = "MAIN", colNames = TRUE)
df$Y <- - df$Y
# Create a simple data frame with UTM coordinates
utm_df <- data.frame(utm_x = df$X, utm_y = df$Y)

utm_sf <- sf::st_as_sf(utm_df, coords = c("utm_x", "utm_y"), crs = 32635)
geo_sf <- st_transform(utm_sf, crs = 4326)
lat_lon <- st_coordinates(geo_sf)

# Create a GeoJSON object from the sf object
geojson_obj <- geojsonio::geojson_json(geo_sf)

# Define the output file path
output_file <- "C:/Users/Thomas Huet/Desktop/temp/first_row.geojson"

# Write the GeoJSON to a file
geojsonio::geojson_write(geojson_obj, file = output_file)

# Print a message to indicate success
print("GeoJSON file created successfully!")


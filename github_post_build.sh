#!/bin/bash

# Define the output file
OUTPUT_FILE="index.html"

# Start the HTML file
cat > $OUTPUT_FILE <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Repository Index</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
    <h1 class="mb-4">Repository Files</h1>
    <ul class="list-group">
EOL

# Find all HTML files except index.html and append to the index.html file
find . -type f -name "*.html" ! -name "index.html" | sort | while read file; do
    filename=$(basename "$file")
    echo "    <li class='list-group-item'><a href='./$filename'>$filename</a></li>" >> $OUTPUT_FILE
done

# Close the HTML file
cat >> $OUTPUT_FILE <<EOL
    </ul>
</body>
</html>
EOL

# Print completion message
echo "Index file updated: $OUTPUT_FILE"

#!/bin/bash

# Define the output file
OUTPUT_FILE="index.html"

# Start the HTML file
cat > $OUTPUT_FILE <<EOL
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

    <title>GPT Wireframes!</title>
  </head>
  <body>
    <h1>GPT Wireframes</h1>
    <div class="container">
      <h4 class="card-title">List of HTML Wireframes</h4>
      <h5 class="card-subtitle mb-2 text-muted">Links will open in new tab</h5>
EOL

# Find all HTML files except index.html and append to the index.html file
find . -type f -name "*.html" ! -name "index.html" | sort | while read file; do
    filename=$(basename "$file")
    echo "<div class='card' style='width: 18rem; margin: 20px;'> <iframe src='./$filename'></iframe>" >> $OUTPUT_FILE
    echo "<div class='card-body'><p><a class='card-link' href='./$filename' target='_blank'>$filename</a></p></div>" >> $OUTPUT_FILE
    echo "</div>" >> $OUTPUT_FILE
done

# Close the HTML file
cat >> $OUTPUT_FILE <<EOL
    </div>
  </div>
</div>

    <!-- Optional JavaScript; choose one of the two! -->

    <!-- Option 1: Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

  </body>
</html>
EOL

# Print completion message
echo "Index file updated: $OUTPUT_FILE"

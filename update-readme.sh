#!/bin/bash

# Render README.Rmd to README.md
Rscript -e 'rmarkdown::render("README.Rmd", encoding="UTF8")'

echo "README updated successfully!"

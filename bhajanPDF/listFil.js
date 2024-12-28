const fs = require('fs');
const path = require('path');

// Path to the folder (adjust to your folder's path)
const folderPath = './';

// Function to get all PDF files with names and extensions
function getFiles(folderPath) {
    // Read all files in the directory
    const files = fs.readdirSync(folderPath);

    // Filter for PDF files and create an array with file name and extension
    const fileList = files
        .filter(file => path.extname(file).toLowerCase() === '.pdf') // Only include .pdf files
        .map((file, index) => {
            const ext = path.extname(file); // Get file extension
            const name = path.basename(file, ext); // Get file name without extension

            return {
                id: index + 1,              // Unique identifier, starting from 1
                name: name,                 // File name without the extension
                fileName: file          // Full file name with the extension
            };
        });

    return fileList;
}

// Get the file list and convert it to JSON
const filesArray = getFiles(folderPath);

// Write the JSON output to a file or display it
const jsonOutput = JSON.stringify(filesArray, null, 2);
console.log(jsonOutput);

// Save the output to a JSON file
fs.writeFileSync('filesList.json', jsonOutput, 'utf8');

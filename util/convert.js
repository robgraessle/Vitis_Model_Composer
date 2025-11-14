var showdown  = require('showdown');
var fs = require('fs');
var path = require('path');

// The converter script will be invoked from the README folder (process.cwd()).
// convert.js is located elsewhere; it reads style.css from __dirname.
var filename = "README.md";

// CLI arg as fallback title
var cliTitle = process.argv[2] || "";

function extractFirstHeading(markdownText) {
  // Match a first ATX heading like: "# Title" or "## Title", up to 6 hashes
  // Allow up to 3 leading spaces per GFM rules for headings.
  var match = markdownText.match(/^\s{0,3}#{1,6}\s+(.*)$/m);
  if (match && match[1]) {
    // Trim trailing/leading whitespace and strip optional trailing hashes
    return match[1].replace(/\s+#+\s*$/,'').trim();
  }
  return "";
}

// Read style.css located next to this script
fs.readFile(path.join(__dirname, 'style.css'), function (err, styleData) {
  if (err) {
    console.error("Failed to read style.css:", err);
    // Continue with empty style rather than aborting entirely
    styleData = Buffer.from("");
  }

  // Read README.md from the current working directory
  var mdPath = path.join(process.cwd(), filename);
  fs.readFile(mdPath, function (err, data) {
    if (err) {
      console.error("Failed to read", mdPath, ":", err);
      process.exit(1);
    }

    var text = data.toString();

    // Determine page title: prefer first heading, then CLI arg, then empty
    var pageTitle = extractFirstHeading(text) || cliTitle || "";

    var converter = new showdown.Converter({
      ghCompatibleHeaderId: true,
      simpleLineBreaks: true,
      ghMentions: true,
      tables: true
    });
    converter.setFlavor('github');

    var preContent = `
    <html>
      <head>
        <title>` + pageTitle + `</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
      </head>
      <body>
        <div id='content'>
    `;

    var postContent = `

        </div>
        <style type='text/css'>` + styleData + `</style>
      </body>
    </html>`;

    var html = preContent + converter.makeHtml(text) + postContent;

    // Write README.html in the same folder; use "w" to overwrite if it exists
    var outPath = path.join(process.cwd(), "README.html");
    fs.writeFile(outPath, html, { flag: "w" }, function(err) {
      if (err) {
        console.error("Failed to write", outPath, ":", err);
        process.exit(1);
      } else {
        console.log("Done, saved to " + outPath);
      }
    });
  });
});

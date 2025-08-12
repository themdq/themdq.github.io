const fs = require("fs");
const path = require("path");
const fm = require("front-matter");

const sourceDir = "./posts_raw";
const targetDir = "./_posts";

// Очистить _posts
fs.rmSync(targetDir, { recursive: true, force: true });
fs.mkdirSync(targetDir);

fs.readdirSync(sourceDir).forEach((file) => {
  if (file.endsWith(".md")) {
    const content = fs.readFileSync(path.join(sourceDir, file), "utf-8");
    const frontmatter = fm(content).attributes;

    if (
      frontmatter["telegram-blog"] === true &&
      frontmatter["status"] === "Ready"
    ) {
      fs.copyFileSync(path.join(sourceDir, file), path.join(targetDir, file));
      console.log(`Copied ${file}`);
    } else {
      console.log(`Skipped ${file}`);
    }
  }
});

// Applies the user-approved proposal canvases to the matching curated Dart templates.
// Run from flutter_app with: node tool/apply_pixel_art_redesigns.js
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const proposalPath = path.join(__dirname, 'pixel_art_redesign_proposals.js');
vm.runInThisContext(fs.readFileSync(proposalPath, 'utf8'), {filename: proposalPath});
const {specs, paint} = globalThis.pixelArtRedesignProposals;

class PixelContext {
  constructor(canvas) { this.canvas = canvas; this.fillStyle = '#000000'; }
  fillRect(x, y, width, height) {
    const color = this.fillStyle.toLowerCase();
    for (let row = Math.max(0, Math.floor(y)); row < Math.min(this.canvas.height, Math.ceil(y + height)); row++) {
      for (let column = Math.max(0, Math.floor(x)); column < Math.min(this.canvas.width, Math.ceil(x + width)); column++) {
        this.canvas.pixels[row * this.canvas.width + column] = color;
      }
    }
  }
}

class PixelCanvas {
  constructor(id) { this.dataset = {id}; this.pixels = []; this._width = 0; this._height = 0; }
  set width(value) { this._width = value; this._reset(); }
  get width() { return this._width; }
  set height(value) { this._height = value; this._reset(); }
  get height() { return this._height; }
  getContext() { return new PixelContext(this); }
  _reset() { if (this._width && this._height) this.pixels = Array(this._width * this._height).fill('#000000'); }
  get nextElementSibling() { return {set textContent(_) {}}; }
}

const templateNumbers = [...specs.keys ? specs.keys() : Object.keys(specs)].map(id => Number(id.slice(6, 9)));
if (templateNumbers.length !== 43 || new Set(templateNumbers).size !== 43) throw new Error('Expected 43 unique approved proposals.');

for (let tier = 1; tier <= 5; tier++) {
  const file = path.join(__dirname, '..', 'lib', 'game', 'pixel_art', 'templates', `tier_${tier}_templates.dart`);
  let source = fs.readFileSync(file, 'utf8');
  for (const number of templateNumbers.filter(value => Math.floor((value - 1) / 20) + 1 === tier)) {
    const id = Object.keys(specs).find(value => Number(value.slice(6, 9)) === number);
    const marker = `  curatedTemplate(\n    number: ${number},`;
    const start = source.indexOf(marker);
    if (start < 0) throw new Error(`Could not find template ${number} in ${file}`);
    const endMarker = '\n  ),';
    const end = source.indexOf(endMarker, start);
    if (end < 0) throw new Error(`Could not find end of template ${number}`);
    const oldBlock = source.slice(start, end + endMarker.length);
    const field = name => {
      const match = oldBlock.match(new RegExp(`${name}: '([^']+)'`));
      if (!match) throw new Error(`Missing ${name} for template ${number}`);
      return match[1];
    };
    const category = oldBlock.match(/category: PixelPictureCategory\.([a-z]+),/)[1];
    const canvas = new PixelCanvas(id);
    paint(canvas, id);
    const [size, palette] = specs[id];
    const paletteIndex = new Map(palette.map((color, index) => [color.toLowerCase(), index]));
    const rows = [];
    for (let row = 0; row < size; row++) {
      let encoded = '';
      for (let column = 0; column < size; column++) {
        const index = paletteIndex.get(canvas.pixels[row * size + column]);
        if (index === undefined) throw new Error(`Unknown rendered color in ${id}`);
        encoded += index === 0 ? '.' : String(index);
      }
      rows.push(`      '${encoded}',`);
    }
    const dartPalette = palette.map(color => `0xFF${color.slice(1).toUpperCase()}`).join(', ');
    const replacement = `  curatedTemplate(\n    number: ${number},\n    id: '${field('id')}',\n    englishName: '${field('englishName')}',\n    turkishName: '${field('turkishName')}',\n    category: PixelPictureCategory.${category},\n    size: ${size},\n    palette: const [${dartPalette}],\n    art: const [\n${rows.join('\n')}\n    ],\n  ),`;
    source = source.slice(0, start) + replacement + source.slice(end + endMarker.length);
  }
  fs.writeFileSync(file, source);
}
console.log('Applied 43 approved Pixel Art redesigns.');

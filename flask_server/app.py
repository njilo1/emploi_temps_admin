from flask import Flask, request, jsonify
from flask_cors import CORS
from docx import Document
import io

app = Flask(__name__)
CORS(app)

@app.route('/parse-word', methods=['POST'])
def parse_word():
    """Receive a .docx file and return parsed JSON data."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    uploaded_file = request.files['file']
    if uploaded_file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    doc_bytes = uploaded_file.read()
    document = Document(io.BytesIO(doc_bytes))
    emplois = []

    if document.tables:
        table = document.tables[0]
        rows = table.rows
        for row in rows[1:]:
            cells = [c.text.strip() for c in row.cells]
            if cells:
                entry = {}
                keys = ['classe', 'jour', 'heure', 'module', 'prof', 'salle']
                for idx, key in enumerate(keys):
                    if idx < len(cells):
                        entry[key] = cells[idx]
                emplois.append(entry)
    else:
        for para in document.paragraphs:
            line = para.text.strip()
            if not line:
                continue
            parts = [p.strip() for p in line.split('|')]
            if len(parts) >= 6:
                entry = dict(zip(['classe', 'jour', 'heure', 'module', 'prof', 'salle'], parts[:6]))
                emplois.append(entry)

    return jsonify({'emplois': emplois})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

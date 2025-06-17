from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from docx import Document
from typing import Dict
import os
import uvicorn

app = FastAPI()


def parse_docx(path: str) -> Dict[str, Dict[str, Dict[str, str]]]:
    """Parse the planning Word document and return a nested dict."""
    planning: Dict[str, Dict[str, Dict[str, str]]] = {}
    doc = Document(path)
    current_class = None
    for para in doc.paragraphs:
        text = para.text.strip()
        if not text:
            continue
        if text.upper().startswith("TIC"):
            current_class = text.replace(' ', '_')
            planning[current_class] = {}
        elif any(jour in text for jour in ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]):
            parts = text.split(':')
            if len(parts) == 2 and current_class:
                day = parts[0].strip()
                hour_course = parts[1].strip()
                if ' ' in hour_course:
                    hour, course = hour_course.split(' ', 1)
                    planning[current_class].setdefault(day, {})[hour] = course
    return planning


@app.post('/parse-word')
async def parse_word(file: UploadFile = File(...)):
    contents = await file.read()
    tmp_path = f"temp_{file.filename}"
    with open(tmp_path, 'wb') as f:
        f.write(contents)
    result = parse_docx(tmp_path)
    os.remove(tmp_path)
    return JSONResponse(content=result)


if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=8000)

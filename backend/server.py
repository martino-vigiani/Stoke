from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from mistralai import Mistral
from datetime import datetime, date, time
from typing import Optional

app = FastAPI(title="CaloriesTracker API")

# CORS middleware per permettere richieste dall'app iOS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mistral API configuration
MISTRAL_API_KEY = "V9V1FMyrhbvrn7boArkKEQwvzpSz2695"
mistral_client = Mistral(api_key=MISTRAL_API_KEY)

# Request/Response models
class FoodDescriptionRequest(BaseModel):
    description: str

class Macros(BaseModel):
    proteine: float
    carboidrati: float
    grassi: float

class FoodParsingResponse(BaseModel):
    kcal: float
    Descrizione: str
    Macros: Macros
    data: Optional[str] = None
    ora: Optional[str] = None
    porzioni: Optional[float] = None
    fonte: Optional[str] = None
    note: Optional[str] = None

# JSON Schema per structured output
NUTRITION_SCHEMA = {
    "type": "object",
    "properties": {
        "kcal": {
            "type": "number",
            "minimum": 0,
            "description": "Totale calorie assunte"
        },
        "Descrizione": {
            "type": "string",
            "description": "Descrizione dettagliata del cibo consumato"
        },
        "Macros": {
            "type": "object",
            "properties": {
                "proteine": {
                    "type": "number",
                    "minimum": 0,
                    "description": "Quantità di proteine in grammi"
                },
                "carboidrati": {
                    "type": "number",
                    "minimum": 0,
                    "description": "Quantità di carboidrati in grammi"
                },
                "grassi": {
                    "type": "number",
                    "minimum": 0,
                    "description": "Quantità di grassi in grammi"
                }
            },
            "required": ["proteine", "carboidrati", "grassi"]
        },
        "data": {
            "type": "string",
            "format": "date",
            "description": "Data del consumo del cibo"
        },
        "ora": {
            "type": "string",
            "format": "time",
            "description": "Orario del consumo del cibo"
        },
        "porzioni": {
            "type": "number",
            "minimum": 0,
            "description": "Numero di porzioni consumate"
        },
        "fonte": {
            "type": "string",
            "description": "Fonte dei dati nutrizionali"
        },
        "note": {
            "type": "string",
            "description": "Note aggiuntive sul consumo del cibo"
        }
    },
    "required": ["kcal", "Descrizione", "Macros"]
}

@app.get("/")
async def root():
    return {"status": "ok", "message": "CaloriesTracker API is running"}

@app.post("/api/parse-food", response_model=FoodParsingResponse)
async def parse_food(request: FoodDescriptionRequest):
    """
    Analizza la descrizione del cibo usando Mistral AI con web search
    e ritorna informazioni nutrizionali strutturate
    """
    try:
        # Prompt per Mistral con istruzioni dettagliate
        system_prompt = """Sei un esperto nutrizionista AI. Dato una descrizione di cibo, devi:

1. Cercare online informazioni nutrizionali accurate usando web search
2. Analizzare la descrizione e identificare tutti gli alimenti menzionati
3. Calcolare i valori nutrizionali totali
4. Fornire una risposta strutturata in JSON

Linee guida:
- Se il nome del cibo è generico (es. "pasta"), fai una ricerca per trovare valori nutrizionali medi
- Se il nome è specifico (es. "Barilla Penne Rigate"), cerca esattamente quel prodotto
- Usa fonti affidabili come database nutrizionali ufficiali
- Se non trovi informazioni esatte, usa valori medi ragionevoli per porzioni standard
- Nella descrizione, fornisci dettagli su cosa hai identificato e le porzioni stimate
- Includi nella fonte da dove hai preso i dati (es. "USDA Database", "produttore", etc.)

Rispondi SOLO con il JSON strutturato, senza testo aggiuntivo."""

        user_message = f"Analizza questo cibo e trova informazioni nutrizionali online: {request.description}"

        # Chiamata a Mistral API con web search e structured output
        chat_response = mistral_client.chat.complete(
            model="mistral-large-latest",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            temperature=0.3,
            max_tokens=1000,
            response_format={
                "type": "json_object",
                "schema": NUTRITION_SCHEMA
            },
            tools=[{"type": "web_search"}],
            tool_choice="any"
        )

        # Parse response
        import json
        response_text = chat_response.choices[0].message.content.strip()
        parsed_data = json.loads(response_text)

        # Aggiungi data e ora corrente se non fornite
        if "data" not in parsed_data or not parsed_data["data"]:
            parsed_data["data"] = datetime.now().strftime("%Y-%m-%d")

        if "ora" not in parsed_data or not parsed_data["ora"]:
            parsed_data["ora"] = datetime.now().strftime("%H:%M:%S")

        # Validate and return
        return FoodParsingResponse(**parsed_data)

    except json.JSONDecodeError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to parse Mistral response as JSON: {str(e)}"
        )
    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing expected field in response: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error processing request: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting CaloriesTracker API server on http://localhost:8000")
    print("📖 API docs available at http://localhost:8000/docs")
    print("🔍 Web search enabled for accurate nutritional data")
    uvicorn.run(app, host="0.0.0.0", port=8000)

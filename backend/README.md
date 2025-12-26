# CaloriesTracker Backend API

Backend server Python per l'app iOS CaloriesTracker che integra Mistral AI per l'analisi nutrizionale.

## Setup

1. Installa le dipendenze:
```bash
cd backend
pip install -r requirements.txt
```

## Avvio Server

```bash
python server.py
```

Il server sarà disponibile su `http://localhost:8000`

## API Endpoints

### `POST /api/parse-food`

Analizza una descrizione di cibo e ritorna informazioni nutrizionali.

**Request Body:**
```json
{
    "description": "2 eggs, toast with butter, orange juice"
}
```

**Response:**
```json
{
    "food_name": "Breakfast",
    "portion_size": "2 eggs, 1 toast, 1 glass",
    "calories": 450,
    "macros": {
        "protein": 18.5,
        "carbs": 42.0,
        "fats": 16.5
    }
}
```

## Documentazione API

Una volta avviato il server, la documentazione interattiva Swagger è disponibile su:
- http://localhost:8000/docs

## Note

- L'API key Mistral è hardcoded nel file `server.py`
- Il server accetta connessioni da qualsiasi origine (CORS aperto per sviluppo)
- Usa il modello `mistral-large-latest` per l'analisi

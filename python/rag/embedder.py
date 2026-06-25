"""
Embedder — converts text to vectors via OpenAI's embedding API.

Design decisions:
    - Uses text-embedding-3-small (industry standard, cost-effective)
    - Batches all texts in a single API call (faster, cheaper than per-chunk calls)
    - Returns raw float lists (ChromaDB accepts these directly)
"""

import os
from typing import List
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

EMBEDDING_MODEL = "text-embedding-3-small"

# Initialize client once at module level
_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def embed_texts(texts: List[str]) -> List[List[float]]:
    """
    Embed a list of text strings into vectors.

    Args:
        texts: list of strings to embed

    Returns:
        list of vectors (each vector = list of 1536 floats),
        in the same order as the input texts
    """
    response = _client.embeddings.create(
        model=EMBEDDING_MODEL,
        input=texts
    )
    return [item.embedding for item in response.data]


def embed_single(text: str) -> List[float]:
    """
    Embed a single text string into a vector.
    Convenience wrapper for query-time embedding.
    """
    return embed_texts([text])[0]


# ============================================================
# Standalone test
# ============================================================
if __name__ == "__main__":
    test_texts = [
        "Payment reconciliation is the process of matching payments.",
        "A tenancy fee is a fixed advertising payment.",
    ]
    vectors = embed_texts(test_texts)
    print(f"Embedded {len(vectors)} texts")
    print(f"Vector dimensions: {len(vectors[0])}")
    print(f"First 5 values of vector 1: {vectors[0][:5]}")

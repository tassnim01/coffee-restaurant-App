const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const OpenAI = require("openai");

const openAiKey = defineSecret("OPENAI_API_KEY");

exports.analyzeReviews = onRequest(
  {
    region: "europe-west1",
    cors: true,
    secrets: [openAiKey],
  },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).json({error: "Méthode non autorisée"});
      return;
    }

    const reviews = Array.isArray(request.body?.reviews)
      ? request.body.reviews
      : [];

    if (reviews.length === 0) {
      response.status(400).json({error: "Aucun avis à analyser"});
      return;
    }

    const openai = new OpenAI({apiKey: openAiKey.value()});
    const prompt = `
Analyse ces avis concernant les plats d'un restaurant.

Avis:
${reviews
  .map((review) =>
    `Produit ${review.productId}: note ${review.rating}/5. ${
      review.comment || "Sans commentaire"
    }`
  )
  .join("\n")}

Retourne uniquement un objet JSON valide avec cette structure:
{
  "summary": "Synthèse générale",
  "strengths": ["Point positif"],
  "issues": ["Point à améliorer"],
  "recommendations": ["Recommandation concrète"]
}
`;

    try {
      const completion = await openai.responses.create({
        model: "gpt-4.1-mini",
        input: prompt,
      });

      const text = completion.output_text
        .replace(/```json/gi, "")
        .replace(/```/g, "")
        .trim();
      response.json(JSON.parse(text));
    } catch (error) {
      console.error(error);
      response.status(500).json({
        error: "Impossible d'analyser les avis",
      });
    }
  }
);

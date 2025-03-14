import express from "express";

const app = express();
const PORT = 3000;

app.use(express.json());

app.post("/game-state", (req, res) => {
  console.log("Raw Request Body:", JSON.stringify(req.body, null, 2));
  try {
    if (!req.body) {
      throw new Error("Empty request body received.");
    }
    res.status(200).json({ message: "Game state received successfully!" });
  } catch (err: any) {
    console.error("Failed to parse JSON:", err.message);
    res.status(400).json({ error: "Invalid JSON received" });
  }
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

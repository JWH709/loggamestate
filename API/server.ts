import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json()); // ⬅️ Important! This allows Express to parse JSON bodies

app.post("/game-state", (req, res) => {
  console.log("Received game state:", req.body);

  res.json({
    message: "Game state received!",
    gameState: req.body,
  });
});

const PORT = 3000;
app.listen(PORT, () =>
  console.log(`Server running on http://localhost:${PORT}`)
);

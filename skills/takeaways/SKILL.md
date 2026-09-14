---
name: takeaways
description: "Extract conclusions and key takeaways from YouTube videos, Instagram Reels/posts, or long-form content, providing a fast comparison and a clear final verdict that directly answers the question or premise in the video's title. Args: <url | text>"
argument-hint: "<url | text>"
---

## Arguments

- `content`: The long-form content to extract takeaways from.
- `rating`: The product rating or pros/cons rating to group takeaways by.
- `video`: The YouTube or Instagram video URL to extract takeaways from.
- `title`: (Optional) The title of the video or post caption if not directly extractable from the URL.

## Steps

1. **Extract Content**: If a YouTube (video/Shorts) or Instagram (Reels/post) URL is provided, obtain the transcript, caption, or page content. If raw text is provided, use it directly.
2. **Identify Video Title / Premise**: Identify the core question, debate, or promise in the video's title or caption (e.g., "Is X worth it?", "Product A vs Product B", "Does Y really work?").
3. **Group Key Takeaways**: Organize the main findings, pros/cons, key features, or product ratings into a concise comparison.
4. **Title-Driven Final Verdict**: Deliver a direct, unambiguous answer to the title's question or premise. Completely resolve any clickbait or teaser framing by stating the final decision, winner, or result up front.



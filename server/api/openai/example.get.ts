import {useOpenAI, safeOpenAIRequest} from '~/server/utils/openai'

export default defineEventHandler(async (event): Promise<string> => {
  const openai = useOpenAI();
  const prompt = "Write a one-sentence bedtime story about a unicorn.";

  const response = await safeOpenAIRequest(() => openai.responses.create({
    model: "gpt-4.1-mini",
    input: prompt,
  }))

  return response.output_text

})
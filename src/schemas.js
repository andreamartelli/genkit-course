import { z } from 'genkit';
import { ai } from './genkit.js';

export const InputQuestionSchema = ai.defineSchema(
  'InputQuestionSchema',
  z.object({
    question: z.string().describe("The user's financial question or topic"),
  }).describe("Input Question Schema")
);

export const MammaAdviceSchema = ai.defineSchema(
  'MammaAdviceSchema',
  z.object({
    advice: z.string().describe("Mamma's financial advice"),
    mammaApprovalRating: z.number().min(1).max(10).describe("Mamma's approval rating from 1 to 10"),
  }).describe("Mamma's structured financial advice")
);

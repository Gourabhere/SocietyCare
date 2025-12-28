
import { GoogleGenAI } from "@google/genai";
import { HousekeepingRecord } from "../types";

// Helper function to generate cleaning report using Gemini API
export const generateCleaningReport = async (records: HousekeepingRecord[]): Promise<string> => {
  // Always use a new instance with the direct process.env.API_KEY as per guidelines
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY as string });
  
  // Filtering records with issues or interesting data
  const issues = records.filter(r => r.status === 'ISSUE' || (r.notes && r.notes.trim().length > 0));
  const completedCount = records.filter(r => r.status === 'COMPLETED').length;
  
  const prompt = `
    You are an expert Facility Manager for a premium residential society.
    Here is the summary of housekeeping activities:
    - Total Inspection Points: ${records.length}
    - Tasks Completed: ${completedCount}
    - Specific Issues/Notes Reported:
    ${issues.map(i => `- ${i.label} (ID: ${i.id}, Type: ${i.type}): [Status: ${i.status}] Notes: ${i.notes}`).join('\n')}

    Please provide a professional, concise executive summary of the maintenance status. 
    Highlight any critical issues that need immediate attention and suggest improvements for tomorrow's shift.
    Format your response in professional Markdown.
  `;

  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: prompt,
    });
    // Accessing .text property directly as per latest SDK guidelines
    return response.text || "Failed to generate AI report. Please check back later.";
  } catch (error) {
    console.error("Gemini Error:", error);
    return "The AI assistant is currently unavailable. Please verify your connection.";
  }
};

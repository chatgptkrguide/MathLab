"use client";

import "katex/dist/katex.min.css";
import katex from "katex";
import DOMPurify from "dompurify";
import { useMemo } from "react";

interface LatexRendererProps {
  text: string;
  className?: string;
}

export default function LatexRenderer({ text, className = "" }: LatexRendererProps) {
  const rendered = useMemo(() => {
    if (!text) return "";

    // Replace $$...$$ (display mode) and $...$ (inline mode)
    let result = text;

    // Display mode: $$...$$
    result = result.replace(/\$\$([\s\S]*?)\$\$/g, (_, tex) => {
      try {
        return katex.renderToString(tex, { displayMode: true, throwOnError: false });
      } catch {
        return `<span class="text-red-500">[LaTeX Error: ${tex}]</span>`;
      }
    });

    // Inline mode: $...$
    result = result.replace(/\$([^$]+?)\$/g, (_, tex) => {
      try {
        return katex.renderToString(tex, { displayMode: false, throwOnError: false });
      } catch {
        return `<span class="text-red-500">[LaTeX Error: ${tex}]</span>`;
      }
    });

    return result;
  }, [text]);

  return (
    <span
      className={className}
      dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(rendered) }}
    />
  );
}

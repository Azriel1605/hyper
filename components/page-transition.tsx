"use client"
import { motion, AnimatePresence } from "framer-motion"
import type React from "react"

import { usePathname } from "next/navigation"
export default function PageTransition({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  return (
    <AnimatePresence mode="wait">
      <motion.main
        key={pathname}
        initial={{ opacity: 0, y: 8, filter: "blur(2px)" }}
        animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
        exit={{ opacity: 0, y: -8, filter: "blur(2px)" }}
        transition={{ duration: 0.35, ease: "easeOut" }}
        className="flex-1"
      >
        {children}
      </motion.main>
    </AnimatePresence>
  )
}

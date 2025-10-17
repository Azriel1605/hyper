"use client"
import Link from "next/link"
import { useState } from "react"
import { motion } from "framer-motion"

export default function Header() {
  const [open, setOpen] = useState(false)
  return (
    <header className="sticky top-0 z-40 bg-background/80 backdrop-blur border-b">
      <div className="mx-auto max-w-5xl px-4 py-3 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <span className="inline-block h-6 w-6 rounded-full bg-primary/80 float" aria-hidden />
          <span className="h-heading font-bold text-xl tracking-tight">HDSC</span>
        </Link>
        <nav className="hidden md:flex items-center gap-6">
          <Link href="/hdsc-test" className="hover:text-primary transition">
            HDSC Test
          </Link>
          <Link href="/hypertension" className="hover:text-primary transition">
            Hypertension
          </Link>
          <Link href="/application" className="hover:text-primary transition">
            Application
          </Link>
          <Link href="/about" className="hover:text-primary transition">
            About Us
          </Link>
          <Link
            href="/hdsc-test"
            className="px-4 py-2 rounded-md bg-primary text-primary-foreground shadow hover:opacity-95 transition"
          >
            Take the Test →
          </Link>
        </nav>
        <button
          aria-label="Toggle Menu"
          onClick={() => setOpen((v) => !v)}
          className="md:hidden inline-flex p-2 rounded-md border"
        >
          <span className="i-lucide-menu size-5" />
        </button>
      </div>
      {open && (
        <motion.div
          initial={{ height: 0, opacity: 0 }}
          animate={{ height: "auto", opacity: 1 }}
          exit={{ height: 0, opacity: 0 }}
          className="md:hidden border-t"
        >
          <div className="px-4 py-3 flex flex-col gap-3">
            <Link href="/hdsc-test" onClick={() => setOpen(false)}>
              HDSC Test
            </Link>
            <Link href="/hypertension" onClick={() => setOpen(false)}>
              Hypertension
            </Link>
            <Link href="/application" onClick={() => setOpen(false)}>
              Application
            </Link>
            <Link href="/about" onClick={() => setOpen(false)}>
              About Us
            </Link>
            <Link
              href="/hdsc-test"
              onClick={() => setOpen(false)}
              className="px-4 py-2 rounded-md bg-primary text-primary-foreground text-center"
            >
              Take the Test →
            </Link>
          </div>
        </motion.div>
      )}
    </header>
  )
}

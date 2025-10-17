import type React from "react"
import type { Metadata } from "next"
import { Geist, Geist_Mono, Inter, Poppins } from "next/font/google"
import { Analytics } from "@vercel/analytics/next"
import "./globals.css"

const _geist = Geist({ subsets: ["latin"] })
const _geistMono = Geist_Mono({ subsets: ["latin"] })

const inter = Inter({ subsets: ["latin"], variable: "--font-inter" })
const poppins = Poppins({ subsets: ["latin"], weight: ["400", "600", "700"], variable: "--font-poppins" })

export const metadata: Metadata = {
  title: "v0 App",
  description: "Created with v0",
  generator: "v0.app",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body className={`font-sans antialiased ${inter.variable} ${poppins.variable}`}>
        <div className="min-h-dvh flex flex-col">{children}</div>
        <Analytics />
      </body>
    </html>
  )
}

'use client'

import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import Link from 'next/link'
import { CheckCircle } from 'lucide-react'

export default function WelcomePage() {
    return (
        <div className="min-h-screen flex items-center justify-center bg-dark-bg p-4 relative overflow-hidden">
            {/* Background Effects */}
            <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0 pointer-events-none">
                <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-green-900/20 rounded-full blur-[100px]" />
            </div>

            <GlassCard className="w-full max-w-md p-10 relative z-10 text-center">
                <div className="flex justify-center mb-6">
                    <CheckCircle className="w-20 h-20 text-green-500" />
                </div>
                
                <h1 className="text-3xl font-bold text-gold mb-4">Email Confirmado!</h1>
                <p className="text-gray-300 mb-8 text-lg">
                    Sua conta foi ativada com sucesso. Agora você pode voltar para o aplicativo e fazer o login.
                </p>

                <div className="space-y-4">
                     <p className="text-sm text-gray-500">
                        Você já pode fechar esta página.
                    </p>
                </div>
            </GlassCard>
        </div>
    )
}

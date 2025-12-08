'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import Link from 'next/link'

export default function AuthPage() {
    const router = useRouter()
    const [isLogin, setIsLogin] = useState(true)
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [fullName, setFullName] = useState('')
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)
    const [role, setRole] = useState<'client' | 'barber'>('client')

    const handleAuth = async (e: React.FormEvent) => {
        e.preventDefault()
        setLoading(true)
        setError(null)

        try {
            if (isLogin) {
                const { error } = await supabase.auth.signInWithPassword({
                    email,
                    password,
                })
                if (error) {
                    setError(error.message)
                } else {
                    // Check if it's the Super Admin
                    if (email === 'aiucmt.kiaaivmtq@gmail.com') {
                        router.push('/admin')
                    } else {
                        // We should ideally check the role here too, but for now dashboard handles it
                        router.push('/dashboard')
                    }
                }
            } else {
                const { error } = await supabase.auth.signUp({
                    email,
                    password,
                    options: {
                        data: {
                            full_name: fullName,
                            role: role, // Pass the selected role
                        },
                    },
                })
                if (error) {
                    setError(error.message)
                } else {
                    // Check if it's the Super Admin
                    if (email === 'aiucmt.kiaaivmtq@gmail.com') {
                        router.push('/admin')
                    } else {
                        router.push('/dashboard')
                    }
                }
            }
        } catch (err) {
            setError('Ocorreu um erro inesperado.')
        } finally {
            setLoading(false)
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-dark-bg p-4 relative overflow-hidden">
            {/* Background Effects */}
            <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0 pointer-events-none">
                <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-gold/20 rounded-full blur-[100px]" />
                <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-blue-900/20 rounded-full blur-[100px]" />
            </div>

            <GlassCard className="w-full max-w-md p-8 relative z-10">
                <div className="text-center mb-8">
                    <h1 className="text-3xl font-bold text-gold mb-2">BarberPremium</h1>
                    <p className="text-gray-400">
                        {isLogin ? 'Bem-vindo de volta' : 'Crie sua conta'}
                    </p>
                </div>

                <form onSubmit={handleAuth} className="space-y-4">
                    {!isLogin && (
                        <>
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Nome Completo / Nome da Barbearia</label>
                                <input
                                    type="text"
                                    value={fullName}
                                    onChange={(e) => setFullName(e.target.value)}
                                    className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50 transition-colors"
                                    placeholder="Seu nome ou da sua loja"
                                    required
                                />
                            </div>

                            <div className="flex gap-4 p-1 bg-white/5 rounded-lg">
                                <button
                                    type="button"
                                    onClick={() => setRole('client')}
                                    className={`flex-1 py-2 rounded-md text-sm font-medium transition-all ${role === 'client' ? 'bg-gold text-black shadow-lg' : 'text-gray-400 hover:text-white'}`}
                                >
                                    Sou Cliente
                                </button>
                                <button
                                    type="button"
                                    onClick={() => setRole('barber')}
                                    className={`flex-1 py-2 rounded-md text-sm font-medium transition-all ${role === 'barber' ? 'bg-gold text-black shadow-lg' : 'text-gray-400 hover:text-white'}`}
                                >
                                    Sou Barbearia
                                </button>
                            </div>
                        </>
                    )}

                    <div>
                        <label className="block text-sm font-medium text-gray-300 mb-1">Email</label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50 transition-colors"
                            placeholder="seu@email.com"
                            required
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-300 mb-1">Senha</label>
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50 transition-colors"
                            placeholder="••••••••"
                            required
                        />
                    </div>

                    {error && (
                        <div className="text-red-400 text-sm text-center bg-red-900/20 p-2 rounded">
                            {error}
                        </div>
                    )}

                    <GoldButton type="submit" isLoading={loading}>
                        {isLogin ? 'Entrar' : (role === 'barber' ? 'Cadastrar Barbearia' : 'Cadastrar Cliente')}
                    </GoldButton>
                </form>

                <div className="mt-6 text-center">
                    <button
                        onClick={() => setIsLogin(!isLogin)}
                        className="text-sm text-gray-400 hover:text-gold transition-colors"
                    >
                        {isLogin ? 'Não tem uma conta? Cadastre-se' : 'Já tem uma conta? Entre'}
                    </button>
                </div>
            </GlassCard>
        </div>
    )
}

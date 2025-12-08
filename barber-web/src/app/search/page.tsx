'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Search, MapPin, Star } from 'lucide-react'
import { Barber } from '@/types'
import Link from 'next/link'

export default function SearchPage() {
    const [searchTerm, setSearchTerm] = useState('')
    const [barbers, setBarbers] = useState<Barber[]>([])
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        fetchBarbers()
    }, [])

    const fetchBarbers = async () => {
        const { data } = await supabase.from('barbers').select('*').eq('status', 'approved')
        if (data) setBarbers(data)
        setLoading(false)
    }

    const filteredBarbers = barbers.filter(b =>
        b.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        b.shop_name?.toLowerCase().includes(searchTerm.toLowerCase())
    )

    const handleJoin = async (barberId: string) => {
        // Logic to "join" the barbershop (e.g., create a relationship record)
        // For now, we'll just simulate it and redirect to booking
        alert('Você agora é cliente desta barbearia!')
        // In a real app, we'd save this preference
    }

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-4xl mx-auto">
                <header className="mb-8">
                    <Link href="/dashboard" className="text-gray-400 hover:text-white text-sm mb-2 block">← Voltar ao Dashboard</Link>
                    <h1 className="text-3xl font-bold text-white mb-4">Encontre sua Barbearia</h1>

                    <div className="relative">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Buscar por nome da barbearia ou barbeiro..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full bg-white/5 border border-white/10 rounded-xl pl-12 pr-4 py-4 text-white focus:border-gold outline-none text-lg"
                        />
                    </div>
                </header>

                <div className="grid gap-6">
                    {loading ? (
                        <div className="text-center text-gray-400">Carregando barbearias...</div>
                    ) : filteredBarbers.length === 0 ? (
                        <div className="text-center text-gray-400">Nenhuma barbearia encontrada.</div>
                    ) : (
                        filteredBarbers.map(barber => (
                            <GlassCard key={barber.id} className="p-6 flex flex-col md:flex-row items-center gap-6 group hover:border-gold/50 transition-all">
                                <div className="w-20 h-20 rounded-full bg-gold/10 flex items-center justify-center flex-shrink-0">
                                    <span className="text-2xl font-bold text-gold">{barber.shop_name?.[0] || barber.name[0]}</span>
                                </div>

                                <div className="flex-1 text-center md:text-left">
                                    <h3 className="text-xl font-bold text-white mb-1">{barber.shop_name || barber.name}</h3>
                                    <p className="text-gray-400 text-sm mb-2 flex items-center justify-center md:justify-start gap-1">
                                        <MapPin className="w-3 h-3" /> {barber.address || 'Localização não informada'}
                                    </p>
                                    <div className="flex items-center justify-center md:justify-start gap-1 text-yellow-400 text-sm">
                                        <Star className="w-3 h-3 fill-current" />
                                        <Star className="w-3 h-3 fill-current" />
                                        <Star className="w-3 h-3 fill-current" />
                                        <Star className="w-3 h-3 fill-current" />
                                        <Star className="w-3 h-3 fill-current" />
                                        <span className="text-gray-500 ml-1">(5.0)</span>
                                    </div>
                                </div>

                                <div className="flex gap-3 w-full md:w-auto">
                                    <Link href={`/book?barber=${barber.id}`} className="flex-1">
                                        <GoldButton className="w-full">Agendar</GoldButton>
                                    </Link>
                                </div>
                            </GlassCard>
                        ))
                    )}
                </div>
            </div>
        </div>
    )
}

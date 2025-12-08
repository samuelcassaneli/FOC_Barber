'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Barber } from '@/types'
import { Trash2, Ban, CheckCircle, Search, MoreVertical } from 'lucide-react'
import Link from 'next/link'

export default function ManageBarbersPage() {
    const [barbers, setBarbers] = useState<Barber[]>([])
    const [loading, setLoading] = useState(true)
    const [searchTerm, setSearchTerm] = useState('')

    useEffect(() => {
        fetchBarbers()
    }, [])

    const fetchBarbers = async () => {
        const { data } = await supabase.from('barbers').select('*')
        if (data) setBarbers(data)
        setLoading(false)
    }

    const handleDelete = async (id: string) => {
        if (!confirm('Tem certeza que deseja remover esta barbearia?')) return

        const { error } = await supabase.from('barbers').delete().eq('id', id)
        if (!error) {
            setBarbers(barbers.filter(b => b.id !== id))
        } else {
            alert('Erro ao deletar: ' + error.message)
        }
    }

    const filteredBarbers = barbers.filter(b =>
        b.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        b.specialty.toLowerCase().includes(searchTerm.toLowerCase())
    )

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-6xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <Link href="/admin" className="text-gray-400 hover:text-white text-sm mb-2 block">← Voltar ao Painel</Link>
                        <h1 className="text-3xl font-bold text-white">Gerenciar Barbearias</h1>
                    </div>
                    <GoldButton className="w-auto">Adicionar Manualmente</GoldButton>
                </header>

                <GlassCard className="p-6 mb-8">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
                        <input
                            type="text"
                            placeholder="Buscar por nome ou especialidade..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full bg-white/5 border border-white/10 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gold outline-none"
                        />
                    </div>
                </GlassCard>

                <div className="bg-white/5 border border-white/10 rounded-xl overflow-hidden">
                    <table className="w-full text-left">
                        <thead>
                            <tr className="bg-white/5 border-b border-white/10">
                                <th className="p-4 text-gray-400 font-medium">Barbeiro/Loja</th>
                                <th className="p-4 text-gray-400 font-medium">Especialidade</th>
                                <th className="p-4 text-gray-400 font-medium">Status</th>
                                <th className="p-4 text-gray-400 font-medium text-right">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                            {loading ? (
                                <tr><td colSpan={4} className="p-8 text-center text-gray-400">Carregando...</td></tr>
                            ) : filteredBarbers.length === 0 ? (
                                <tr><td colSpan={4} className="p-8 text-center text-gray-400">Nenhum barbeiro encontrado.</td></tr>
                            ) : (
                                filteredBarbers.map((barber) => (
                                    <tr key={barber.id} className="border-b border-white/5 hover:bg-white/5 transition-colors">
                                        <td className="p-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 rounded-full bg-gray-700 overflow-hidden">
                                                    {barber.photo_url ? (
                                                        <img src={barber.photo_url} alt={barber.name} className="w-full h-full object-cover" />
                                                    ) : (
                                                        <div className="w-full h-full flex items-center justify-center text-xs text-gray-400">IMG</div>
                                                    )}
                                                </div>
                                                <span className="text-white font-medium">{barber.name}</span>
                                            </div>
                                        </td>
                                        <td className="p-4 text-gray-300">{barber.specialty}</td>
                                        <td className="p-4">
                                            <span className="px-2 py-1 rounded-full text-xs font-bold bg-green-500/20 text-green-400">
                                                Ativo
                                            </span>
                                        </td>
                                        <td className="p-4 text-right">
                                            <div className="flex justify-end gap-2">
                                                <button className="p-2 hover:bg-white/10 rounded-lg text-gray-400 hover:text-white" title="Bloquear">
                                                    <Ban className="w-4 h-4" />
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(barber.id)}
                                                    className="p-2 hover:bg-red-500/20 rounded-lg text-gray-400 hover:text-red-400"
                                                    title="Excluir"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    )
}

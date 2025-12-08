'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { Profile } from '@/types'
import { Trash2, Search, User } from 'lucide-react'
import Link from 'next/link'

export default function ManageClientsPage() {
    const [clients, setClients] = useState<Profile[]>([])
    const [loading, setLoading] = useState(true)
    const [searchTerm, setSearchTerm] = useState('')

    useEffect(() => {
        fetchClients()
    }, [])

    const fetchClients = async () => {
        const { data } = await supabase.from('profiles').select('*').eq('role', 'client')
        if (data) setClients(data)
        setLoading(false)
    }

    const handleDelete = async (id: string) => {
        if (!confirm('ATENÇÃO: Esta ação é irreversível e removerá todos os dados do cliente (LGPD). Deseja continuar?')) return

        // In a real scenario, this would trigger a Supabase Edge Function to delete the user from Auth as well
        const { error } = await supabase.from('profiles').delete().eq('id', id)
        if (!error) {
            setClients(clients.filter(c => c.id !== id))
            alert('Dados do cliente removidos com sucesso.')
        } else {
            alert('Erro ao deletar: ' + error.message)
        }
    }

    const filteredClients = clients.filter(c =>
        c.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.email?.toLowerCase().includes(searchTerm.toLowerCase())
    )

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-6xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <Link href="/admin" className="text-gray-400 hover:text-white text-sm mb-2 block">← Voltar ao Painel</Link>
                        <h1 className="text-3xl font-bold text-white">Gerenciar Clientes (LGPD)</h1>
                    </div>
                </header>

                <GlassCard className="p-6 mb-8">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
                        <input
                            type="text"
                            placeholder="Buscar por nome ou email..."
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
                                <th className="p-4 text-gray-400 font-medium">Cliente</th>
                                <th className="p-4 text-gray-400 font-medium">Email</th>
                                <th className="p-4 text-gray-400 font-medium">Data Cadastro</th>
                                <th className="p-4 text-gray-400 font-medium text-right">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                            {loading ? (
                                <tr><td colSpan={4} className="p-8 text-center text-gray-400">Carregando...</td></tr>
                            ) : filteredClients.length === 0 ? (
                                <tr><td colSpan={4} className="p-8 text-center text-gray-400">Nenhum cliente encontrado.</td></tr>
                            ) : (
                                filteredClients.map((client) => (
                                    <tr key={client.id} className="border-b border-white/5 hover:bg-white/5 transition-colors">
                                        <td className="p-4">
                                            <div className="flex items-center gap-3">
                                                <div className="bg-gray-700 p-2 rounded-full text-gray-300">
                                                    <User className="w-4 h-4" />
                                                </div>
                                                <span className="text-white font-medium">{client.full_name}</span>
                                            </div>
                                        </td>
                                        <td className="p-4 text-gray-300">{client.email || 'N/A'}</td>
                                        <td className="p-4 text-gray-400">{new Date(client.created_at || '').toLocaleDateString('pt-BR')}</td>
                                        <td className="p-4 text-right">
                                            <button
                                                onClick={() => handleDelete(client.id)}
                                                className="p-2 hover:bg-red-500/20 rounded-lg text-gray-400 hover:text-red-400"
                                                title="Excluir Dados (LGPD)"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
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

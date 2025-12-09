'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { useRouter } from 'next/navigation'
import { Trash2, Shield, User, Scissors } from 'lucide-react'

interface UserProfile {
    id: string
    full_name: string
    email: string
    role: 'admin' | 'barber' | 'client'
    shop_code?: string
    created_at: string
}

export default function AdminDashboard() {
    const router = useRouter()
    const [users, setUsers] = useState<UserProfile[]>([])
    const [loading, setLoading] = useState(true)
    const [stats, setStats] = useState({ barbers: 0, clients: 0 })

    useEffect(() => {
        checkAdmin()
        fetchUsers()
    }, [])

    const checkAdmin = async () => {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user || user.email !== 'aiucmt.kiaaivmtq@gmail.com') {
            router.push('/auth')
        }
    }

    const fetchUsers = async () => {
        setLoading(true)
        const { data, error } = await supabase
            .from('profiles')
            .select('*')
            .order('created_at', { ascending: false })

        if (data) {
            setUsers(data as UserProfile[])
            setStats({
                barbers: data.filter(u => u.role === 'barber').length,
                clients: data.filter(u => u.role === 'client').length
            })
        }
        setLoading(false)
    }

    const deleteUser = async (id: string) => {
        if (!confirm('Tem certeza? Isso apagará todos os dados deste usuário.')) return

        // 1. Delete from profiles (Cascade should handle the rest if configured, otherwise delete relations first)
        const { error } = await supabase.from('profiles').delete().eq('id', id)
        
        if (error) {
            alert('Erro ao deletar: ' + error.message)
        } else {
            // Note: Deleting from auth.users requires Service Role key on backend, 
            // but deleting profile removes them from the app logic.
            setUsers(users.filter(u => u.id !== id))
        }
    }

    if (loading) return <div className="min-h-screen bg-dark-bg flex items-center justify-center text-gold">Carregando Painel Admin...</div>

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-7xl mx-auto">
                <div className="flex justify-between items-center mb-10">
                    <h1 className="text-3xl font-bold text-white">Painel Super Admin</h1>
                    <div className="flex gap-4">
                        <div className="bg-white/5 px-4 py-2 rounded-lg border border-white/10">
                            <span className="text-gold font-bold">{stats.barbers}</span> Barbeiros
                        </div>
                        <div className="bg-white/5 px-4 py-2 rounded-lg border border-white/10">
                            <span className="text-blue-400 font-bold">{stats.clients}</span> Clientes
                        </div>
                    </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    {/* Barbers List */}
                    <section>
                        <h2 className="text-xl text-gold mb-4 flex items-center gap-2">
                            <Scissors size={20} />
                            Barbearias
                        </h2>
                        <div className="space-y-4">
                            {users.filter(u => u.role === 'barber').map(user => (
                                <GlassCard key={user.id} className="p-4 flex justify-between items-center group hover:bg-white/5 transition-all">
                                    <div>
                                        <h3 className="font-bold text-white">{user.full_name || 'Sem nome'}</h3>
                                        <p className="text-sm text-gray-400">{user.email}</p>
                                        <p className="text-xs text-gold mt-1">Código: {user.shop_code || 'N/A'}</p>
                                    </div>
                                    <button 
                                        onClick={() => deleteUser(user.id)}
                                        className="p-2 hover:bg-red-500/20 rounded-full text-gray-500 hover:text-red-500 transition-colors"
                                    >
                                        <Trash2 size={18} />
                                    </button>
                                </GlassCard>
                            ))}
                        </div>
                    </section>

                    {/* Clients List */}
                    <section>
                        <h2 className="text-xl text-blue-400 mb-4 flex items-center gap-2">
                            <User size={20} />
                            Clientes
                        </h2>
                        <div className="space-y-4">
                            {users.filter(u => u.role === 'client').map(user => (
                                <GlassCard key={user.id} className="p-4 flex justify-between items-center">
                                    <div>
                                        <h3 className="font-bold text-white">{user.full_name || 'Sem nome'}</h3>
                                        <p className="text-sm text-gray-400">{user.email}</p>
                                    </div>
                                    <button 
                                        onClick={() => deleteUser(user.id)}
                                        className="p-2 hover:bg-red-500/20 rounded-full text-gray-500 hover:text-red-500 transition-colors"
                                    >
                                        <Trash2 size={18} />
                                    </button>
                                </GlassCard>
                            ))}
                        </div>
                    </section>
                </div>
            </div>
        </div>
    )
}
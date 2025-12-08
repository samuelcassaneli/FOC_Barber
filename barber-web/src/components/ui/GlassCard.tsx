import { cn } from '@/lib/utils'

interface GlassCardProps extends React.HTMLAttributes<HTMLDivElement> {
    children: React.ReactNode
    className?: string
}

export function GlassCard({ children, className, ...props }: GlassCardProps) {
    return (
        <div
            className={cn(
                "backdrop-blur-md bg-white/10 border border-white/20 rounded-xl shadow-xl",
                className
            )}
            {...props}
        >
            {children}
        </div>
    )
}

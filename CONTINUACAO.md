# FOC Barber - Continuação do Desenvolvimento

**Última atualização:** 23/12/2024 00:30

---

## Estado Atual

### ✅ Concluído

1. **APKs Flutter Gerados**
   - `FOC_Barber_Cliente.apk` (23 MB) - App para clientes
   - `FOC_Barber_Shop.apk` (23 MB) - App para barbearias
   - Localizados na pasta raiz do projeto

2. **Código Flutter Corrigido**
   - Flavors Android configurados (cliente/barbearia)
   - Erros de compilação corrigidos (BookingStatus, BarberModel)
   - Compatibilidade Supabase Stream corrigida

3. **Webapp Next.js**
   - Formulário de criação de barbearias atualizado com campos white-label
   - Cliente Supabase com fallback para build estático
   - Workflow GitHub Actions atualizado

4. **Migração SQL Criada**
   - Arquivo: `barber-web/supabase/migrations/20251223_add_whitelabel_columns.sql`

---

## ⏳ Pendente - Fazer na Próxima Sessão

### 1. Adicionar Secrets no GitHub Actions
Acessar: https://github.com/samuelcassaneli/FOC_Barber/settings/secrets/actions

Adicionar:
- `NEXT_PUBLIC_SUPABASE_URL` = `https://zynmvmxdluevuwigbadz.supabase.co`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` = `sb_publishable_9w0K7O3Sun2zl2qIQwX33g_wGkVsy6f`

### 2. Executar SQL no Supabase
Acessar: https://supabase.com/dashboard/project/zynmvmxdluevuwigbadz/sql/new

```sql
-- Adicionar colunas white-label
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS website TEXT;
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS cnpj TEXT;
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS primary_color TEXT DEFAULT '#D4AF37';
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS secondary_color TEXT DEFAULT '#1C1C1E';
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS invite_code TEXT UNIQUE;
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS plan_type TEXT DEFAULT 'free';
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS plan_expires_at TIMESTAMPTZ;
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS max_barbers INTEGER DEFAULT 5;
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS whatsapp TEXT;
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS instagram TEXT;
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS facebook TEXT;
ALTER TABLE public.barbershops ADD COLUMN IF NOT EXISTS owner_email TEXT;

-- Índice para invite_code
CREATE INDEX IF NOT EXISTS idx_barbershops_invite_code ON public.barbershops(invite_code);

-- Função para gerar código de convite
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    result TEXT := '';
    i INTEGER;
BEGIN
    FOR i IN 1..8 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Trigger para gerar código automaticamente
CREATE OR REPLACE FUNCTION set_invite_code()
RETURNS TRIGGER AS $$
DECLARE
    new_code TEXT;
    code_exists BOOLEAN;
BEGIN
    IF NEW.invite_code IS NULL THEN
        LOOP
            new_code := generate_invite_code();
            SELECT EXISTS(SELECT 1 FROM public.barbershops WHERE invite_code = new_code) INTO code_exists;
            EXIT WHEN NOT code_exists;
        END LOOP;
        NEW.invite_code := new_code;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_barbershop_invite_code ON public.barbershops;
CREATE TRIGGER set_barbershop_invite_code
    BEFORE INSERT ON public.barbershops
    FOR EACH ROW
    EXECUTE FUNCTION set_invite_code();
```

### 3. Re-executar Workflow no GitHub
Após adicionar os secrets, ir em Actions e re-executar o workflow que falhou.

### 4. Testar Criação de Barbearia
Acessar: https://foc-barber.vercel.app/admin/barbershops/new

---

## URLs Importantes

| Serviço | URL |
|---------|-----|
| Webapp (Vercel) | https://foc-barber.vercel.app |
| GitHub Repo | https://github.com/samuelcassaneli/FOC_Barber |
| Supabase Dashboard | https://supabase.com/dashboard/project/zynmvmxdluevuwigbadz |
| Supabase SQL Editor | https://supabase.com/dashboard/project/zynmvmxdluevuwigbadz/sql/new |
| GitHub Secrets | https://github.com/samuelcassaneli/FOC_Barber/settings/secrets/actions |
| GitHub Actions | https://github.com/samuelcassaneli/FOC_Barber/actions |

---

## Estrutura do Projeto

```
barber_premium/
├── lib/                    # Flutter - código compartilhado
├── android/                # Android config + flavors
│   └── app/src/
│       ├── cliente/        # Flavor Cliente
│       └── barbearia/      # Flavor Barbearia
├── barber-web/             # Next.js webapp
│   ├── src/app/            # Páginas
│   └── supabase/migrations # Migrações SQL
├── FOC_Barber_Cliente.apk  # APK gerado
├── FOC_Barber_Shop.apk     # APK gerado
└── CONTINUACAO.md          # Este arquivo
```

---

## Fluxo White-Label (Como deve funcionar)

1. **Admin** cria barbearia no painel web
2. Sistema gera **código de convite** único (ex: ABC12345)
3. Admin envia código para o **proprietário da barbearia**
4. Proprietário baixa o app **FOC Barber Shop**
5. Proprietário se cadastra usando o código
6. Proprietário personaliza sua barbearia (logo, cores, serviços)
7. **Clientes** baixam o app **FOC Barber Cliente**
8. Clientes usam o código para encontrar a barbearia
9. Clientes agendam serviços

---

## Comandos Úteis

```bash
# Build APK Cliente
flutter build apk --flavor cliente -t lib/main_cliente.dart --release

# Build APK Barbearia
flutter build apk --flavor barbearia -t lib/main_barbearia.dart --release

# Build Webapp
cd barber-web && npm run build

# Rodar webapp local
cd barber-web && npm run dev
```

---

## Próximos Passos (Após pendências)

- [ ] Testar criação de barbearia completa
- [ ] Implementar tela de login com código de convite no app Flutter
- [ ] Conectar app Flutter com barbearia específica
- [ ] Testar fluxo completo: Admin → Barbearia → Cliente

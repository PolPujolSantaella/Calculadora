# CompiladorCalculadora
Aquest repositori conté la part frontal d'un compilador per a una calculadora.

## Aprenentatges
- Taula de símbols
- Anàlisi lèxic, sintàctic, semàntic
- Atributs i comprovació de tipus
- Utilització conjunta de Flex, Bison i Symtab

## Compilació
1. Clona el repositori:
   ```bash
   git clone https://github.com/PolPujolSantaella/CompiladorCalculadora.git
   cd CompiladorCalculadora
   ```

2. Compila el projecte
   ```bash
   make all
   ```

## Execució
Per provar el joc de proves que he realitzat només cal fer un:
   ```bash
   make eg
   ```
Aquest et genera un arxiu ex_sortida.out que conté la sortida corresponent.

## Per netejar-ho tot menys arxius fonts
   ```bash
   make clean
   ```
# Descripció del Projecte
Aquest projecte és la part frontal d'un compilador per a una calculadora. Permet analitzar, interpretar i executar expressions aritmètiques introduïdes per l'usuari, incloent operacions de suma, resta, multiplicació, divisió, potència, funcions trigonomètriques (sin, cos, tan) i expressions booleanes.

El compilador processa les expressions a través d'un anàlisi lèxic i sintàctic, convertint l'expressió en una sèrie de tokens, verificant la sintaxi i generant el resultat calculat.

El funcionament del compilador pasa per processar les expressions mitjançant l'anàlisis lèxic i sintàctic. Converteix la expresió en una serie de tokens,
verifica la sintaxis i després genera un resultat calculat.

## Components del codi
· Anàlisi Lèxic: Descompon l'expressió en tokens individuals, com números i operadors.
· Anàlisi Sintàctic: Avalua l'estructura de l'expressió per garantir que segueixi les regles matemàtiques.
· Anàlisi Semàntic: Verifica que l'expressió tingui sentit matemàtic, comprovant errors com divisió per zero.

## Decissions de disseny
## Limitacions



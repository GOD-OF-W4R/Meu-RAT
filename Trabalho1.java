import java.io.*;
import java.text.DecimalFormat;

public class Trabalho1
{
  public static void main ( String [] args ) throws IOException 
  {
	BufferedReader walk = new BufferedReader ( new InputStreamReader (System.in));
	DecimalFormat mt = new DecimalFormat ("###,###,##0.00 MT");
	DecimalFormat litros = new DecimalFormat ("###,###,##0.00 Litros");
	DecimalFormat toneladas = new DecimalFormat ("###,###,##0.00 Toneladas");
	DecimalFormat caixas = new DecimalFormat ("###,###,##0.00 Caixas");
    
	//inteiros
	int qC = 0, qM = 0, qA = 0, qt = 0, ql = 0, qca = 0, op, quantidade, contadorPessoas = 0, contador_dos_penalizados = 0, contador_Combustivel = 0, contador_Alimentos = 0, contador_Medicamentos = 0;
	final int TX3 = 500, TX4 = 2000, DESPESAS = 1000000;
	
	//boolean
	boolean menorC = false, menorA = false, menorM = false, passou_opcao1 = false, esta_dentro_do_orcamento = false;
	
	//decimais
	float vtC = 0, vtM = 0, vtA = 0, vTP = 0, acum = 0, vP = 0, tx = 0, pc, pq, pb, p = 0, preco;
	final float TX1 = (2/100f), TX2 = (8/100f), TX5 = (3/100f), TX6 = (5/100f), TXP = (10/100f);
	
	//caracters
	char tp,tpC,querR,querCe,eT='k';

    
	//VARIAVEIS EXPLICADAS:	
	/*	
	pc = preco do medicamento por caixa
	pq = preco do alimento por tonelada
	pb = preco do combustivel por litro

	contadorPessoas = contador de pessoas que passaram pela opcao 1 do menu, para ser utilizado na opcao 9 do menu
	contador_dos_penalizados = contador de pessoas que receberam penalizacao, para ser utilizado na opcao 9 do menu
	contador_Combustivel = contador de remessas de combustivel, para ser utilizado na opcao 8 do menu
	contador_Alimentos = contador de remessas de alimento, para ser utilizado na opcao 8 do menu
	contador_Medicamentos = contador de remessas de medicamento, para ser utilizado na opcao 8 do menu


	qC = quantidade total de combustivel
	qA = quantidade total de alimento
	qM = quantidade total de medicamento
	
	qt = quantidade de alimento por tonelada
	ql = quantidade de combustivel por litro
	qca = quantidade de caixas de medicamento
	
	op = opcao do menu
	
	vtC = valor total do combustivel
	vtA = valor total do alimento
	vtM = valor total do medicamento
	vTP = valor total das penalizacoes
	acum = valor total da importacao
	vP = valor a pagar do cliente

	tp = tipo do produto
	tpC = tipo do combustivel
	querR = se o alimento precisa de refrigeracao ou nao
	querCe = se o medicamento precisa de controle especial ou nao
	eT = estado da remessa, se esta atrasada ou em curso

	boolean menorC, menorA, menorM = variaveis booleanas para saber qual o tipo de produto com menor valor total
	boolean passou_opcao1 = variavel booleana para saber se o usuario ja passou pela opcao 1 do menu, para que possa ser utilizado na opcao 6 do menu

	

	tx = taxa a ser aplicada dependendo do tipo de produto e das caracteristicas do mesmo
	p = valor da penalizacao a ser aplicada dependendo do estado da remessa
	quantidade = variavel que ira guardar a quantidade que o usuario introduziu, seja ele quantidade de combustivel, alimento ou medicamento, para que seja utilizado para o recibo ao vizualizar o valor a pagar ao cliente na opcao 1 do menu	
	preco = variavel que ira guardar o preco do produto, seja ele o preco do litro do combustivel, alimento ou medicamento, para que seja utilizado para o recibo ao vizualizar o valor a pagar ao cliente na opcao 1 do menu
	*/
	
        //pedido dos precos fora do nosso loop principal do programa, para que o usuario nao seja sempre questionado sobre o valor	
		System.out.println("\n\n\n\n-------------  Bem Vindo ao programa de importacao de produtos! ---------------");
		System.out.println("\nPara que nao sejas sempre questionado sobre os precos das remessas dentro do programa, por favor");
	    do  
	    {
		
		   System.out.print ("Introduza o preco base por litro do combustivel (>0): ");
		   pb = Float.parseFloat(walk.readLine ( ));
		
		   if (pb <= 0) 
		   {
			  System.out.println ("Valor Invalido ! Tente novamente! ");
		   }
		   
	    }while (pb <= 0);
	
	
	    do 
	    {	
		   System.out.print ("Introduza o preco por tonelada do alimento (>0): ");
		   pq = Float.parseFloat(walk.readLine ( ));
		
		   if (pq <= 0) 
		   {
			  System.out.println ("Valor Invalido! Tente novamente !");
		   }
	    }while (pq <= 0);
	    
	
	    do 
	    {
		
		   System.out.print ("Introduza o preco por caixa do Medicamento: ");
		   pc = Float.parseFloat(walk.readLine () );
		
		   if (pc <= 0) 
		   {
			  System.out.println ("Valor Invalido! Tente novamente");
		   }
		
	    }while (pc <= 0);
	    
	    
	    
	    //loop principal do programa
	    do 
	    {
	    	//Inicio do menu
	    	System.out.println("\n====================================================");
	    	System.out.println("||-------------------  Menu ----------------------||");
	    	System.out.println("|| 1. Receber dados e calcular o valor a pagar.   ||");
	    	System.out.println("|| 2. Quantidade de produtos de cada tipo.        ||");
	    	System.out.println("|| 3. Valor total pago por cada tipo de produto.  ||"); 
	    	System.out.println("|| 4. Valor total pago das importacoes.           ||");
	    	System.out.println("|| 5. Valor total de penalizacoes.                ||");
	    	System.out.println("|| 6. O tipo de produto com menor custo total.    ||");
	    	System.out.println("|| 7. Ver o estado da empresa.                    ||");
	    	System.out.println("|| 8. Relatorios de todos os produtos numa tabela.||");
			System.out.println("|| 9. Relatorio da empresa numa tabela.           ||");
	    	System.out.println("|| 10. Dados dos programadores.                   ||");
	    	System.out.println("|| 11. Sair!                                      ||");
	    	System.out.print  ("|| -> ");
	    	op = Integer.parseInt(walk.readLine()); //receber a resposta do menu ca, para que a resposta fique dentro da tabela do menu
	    	System.out.println("====================================================\n");

            switch(op) 
            {
            	case 1:

					//receber o tipo do produto, e validar a resposta
            		do 
        	    	{
        			
        	    		System.out.println("Introduza o tipo de produto: Combustivel (C) / Alimento (A) / Medicamento (M)");
        	    		tp = walk.readLine().charAt(0);
        			
        	    		if (tp != 'c' & tp != 'C' & tp != 'A' & tp != 'a' & tp != 'M' & tp != 'm' ) 
        	    		{
        	    			System.out.println ("Caracter Invalido! Tente novamente!");
        	    		}
        	    	}
        	    	while (tp != 'c' & tp != 'C' & tp != 'A' & tp != 'a' & tp != 'M' & tp != 'm');
        		
        	    	//dependendo do tipo do produto, receber as caracteristicas do mesmo, e calcular o valor a pagar do cliente
        	    	switch (tp) 
        	    	{
						//caso o produto seja combustivel, receber a quantidade de litros, o tipo de combustivel, e calcular o valor a pagar do cliente
        	    		case 'c':
        	    		case 'C': 

						//receber a quantidade de litros, e validar a resposta
        	    		do 
        	    		{
        	    			System.out.println ("Introduza a quantidade de litros de combustivel: ");
        	    			ql = Integer.parseInt(walk.readLine () );   

        	    			if ( ql <=0)
        	    			{
        	    				System.out.println ("Valor invalido ! Tente novamente! ");
        	    			}
        	    		} while(ql<=0);
        	    			
						//calcular o valor a pagar do cliente, e atualizar a quantidade total de combustivel
        	    		vP = pb * ql;
        	    		qC = qC + ql;
        		
        	    		
						//receber o tipo de combustivel, e validar a resposta
        	    		do 
        	   			{
        			   
        	   				System.out.println("Que tipo de combustivel possui (G-Gasolina ou S-Gasoleo)?: ");
        	   				tpC = walk.readLine().charAt(0);
        			   
        	    			if ( tpC != 'G' && tpC != 'g' && tpC != 'S' && tpC != 's' ) 
        	    			{
        	    				System.out.println ("Caracter Invalido! Tente novamente");  
        	   				}

        	   			}while (tpC != 'G' && tpC != 'g' && tpC != 'S' && tpC != 's' );
        		      
						//calcular o valor a pagar do cliente dependendo do tipo de combustivel, e atualizar o valor total do combustivel
        	    		switch(tpC) 
        	    		{
        	   				case 'g':
        	   				case 'G': tx = vP * TX6; break; 
        		
        	   				case 'C':
        	   				case 'c': tx = vP * TX5; break;
        	    				
        	    		}

						//calcular o valor a pagar do cliente dependendo da taxa, e atualizar o valor total do combustivel
        	    		vP = vP + tx;
        	    		vtC = vtC + vP;
						contador_Combustivel++;

        		        break;
        		        
						//caso o produto seja alimento, receber a quantidade de toneladas, se precisa de refrigeracao ou nao, e calcular o valor a pagar do cliente
        	    		case 'a':
        	    		case 'A': 
        			    
						//receber a quantidade de toneladas, e validar a resposta
        	    		do 
        	    		{
        	    			System.out.print("Digite a quantidade de Alimentos (>0): ");
        	   				qt = Integer.parseInt(walk.readLine());
        			   
            				if (qt <=0)
            				{
        	    				System.out.println ("Quantidade Invalida ! Tente novamente!");   
        	    			}
        				   
        	    		}while ( qt <=0);
        	    			
						//calcular o valor a pagar do cliente, e atualizar a quantidade total de alimento
        	   			vP = qt * pq;
        	   			qA = qA + qt;
        		       
						//receber se o alimento precisa de refrigeracao ou nao, e validar a resposta
        	    		do
        	    		{
        		   	   
        	    			System.out.println("Deseja refrigeracao (S-Sim /N-Nao)?: ");
        	   				querR = walk.readLine().charAt(0);
        		    	   
        	   				if (querR != 'S' && querR != 's' && querR != 'N' && querR != 'n')
        	   				{
        	   					System.out.println ("O caracter invalido ! Tente novamente:");
            				}
        		    	   
        	    		}while ( querR != 'S' && querR != 's' && querR != 'N' && querR != 'n');	    			
        		       
						
						//calcular o valor a pagar do cliente dependendo se o alimento precisa de refrigeracao ou nao, e atualizar o valor total do alimento
        	    		switch (querR) 
        	    		{
        	   				case 's':
        	   				case 'S': vP = vP + TX4;break;
        		          
        		 
        	   				case 'n':
        	   				case 'N': vP = vP + TX3; break;
        	
            			}
        	    		
						//calcular o valor a pagar do cliente dependendo da taxa, e atualizar o valor total do alimento
        	    		vtA = vtA + vP; 
						contador_Alimentos++;
        	    		break;               
        	    	
        	    		//caso o produto seja medicamento, receber a quantidade de caixas, se precisa de controle especial ou nao, e calcular o valor a pagar do cliente
        	        	case'm':
        	    	    case'M':
        	    	    do
        	   			{
        	   				System.out.println ("Introduza a quantidade de caixas (>0):");
        	   				qca = Integer.parseInt(walk.readLine());
        				  
            				if (qca <=0)
            				{
        	    				System.out.println ("Quantidade de caixas invalida! Tente novamente!");
        	    			}
        	    				
        	    		}while (qca <=0);
        	    			
        			    //calcular o valor a pagar do cliente, e atualizar a quantidade total de medicamento
        	   			vP= qca * pc;
        	   			qM = qM + qca;
        			   

						//receber se o medicamento precisa de controle especial ou nao, e validar a resposta
        	   			do
        	   			{
            				System.out.println ("Quer controle especial (S-Sim / N-Nao)");
            				querCe = walk.readLine ().charAt(0);
        				  
        	    			if ( querCe != 'S' && querCe != 's' && querCe != 'N' && querCe != 'n')
        	    			{
        	    				System.out.println (" Caracter invalido! Tente novamente!");
        	   				}
        			  
            			}while ( querCe != 'S' && querCe != 's' && querCe != 'N' && querCe != 'n');
        	    		
						
						//calcular o valor a pagar do cliente dependendo se o medicamento precisa de controle especial ou nao, e atualizar o valor total do medicamento
        	   			switch (querCe)
        	    		{
        	    			case 'S':
        	    			case 's':tx = vP*TX2;  break;
        	    			
        	    			case 'n':
        	   				case 'N':tx = vP*TX1; break;
        	   			}
        			   

						//calcular o valor a pagar do cliente dependendo da taxa, e atualizar o valor total do medicamento
        	    		vP = vP + tx;
        	    		vtM += vP;
						contador_Medicamentos++;
        	    		
        	    		break;
        	    			
        	    	}
        	    	

					//receber o estado da remessa, e validar a resposta
        	    	do 
    	    		{
    	    			System.out.println("Introduza o estado da remessa (C-Em curso / A-Atrasado): ");
    	    			eT = walk.readLine().charAt(0);

						if (eT == 'A' || eT == 'a')
						{
							contador_dos_penalizados++;
						}
    	    			
    	    			if (eT != 'a' && eT != 'A' && eT != 'c' && eT != 'C')
    	    				System.out.println("Opcao invalida, tente de novo!");
    	    			
    	    		}while(eT != 'a' && eT != 'A' && eT != 'c' && eT != 'C');
        	    	

					//calcular o valor a pagar do cliente dependendo do estado da remessa, e atualizar o valor total das penalizacoes
        	    	switch (eT) 
        	    	{
        	    		case 'a':
        	    		case 'A': p = vP*TXP;break;
        	    			
        	    		case 'c':
        	    		case 'C': p = 0; break;
        	    	}
        	    	

					//atualizar o valor a pagar do cliente dependendo da penalizacao, e atualizar o valor total das penalizacoes e o valor total da importacao
        	    	vP +=p;
        	    	vTP +=p;
        	    	acum +=vP;
					contadorPessoas++;
					

					//dependendo do tipo do produto, atualizar a variavel quantidade e preco para que seja utilizado no recibo ao vizualizar o valor a pagar ao cliente
					if (tp == 'C' || tp == 'c')
					{
						quantidade = ql;
						preco = pb;
						
					}
					else
					{
						if (tp == 'A' || tp == 'a')
						{
							quantidade = qt;
							preco = pq;
						}
						else
						{
							quantidade = qca;
							preco = pc;
						}
					}
        	    	
					//recibo para o cliente
        	    	System.out.println ("====================================================================================================================");
					System.out.println ("|| Remessa || Estado || preco por uma quantidade || Quantidades possuidas ||  Penalizacao  || Valor total a pagar ||"); 	
					System.out.println ("||---------||--------||--------------------------||-----------------------||---------------||---------------------||");
            		System.out.printf  ("%c%c%6c%4c%c%5c%4c%c%16s%11c%c%13d%11c%c%13s%3c%c%16s%6c%c\n" ,'|','|',tp,'|','|',eT,'|','|',mt.format(preco),'|','|',quantidade,'|','|',mt.format(p),'|','|',mt.format(vP),'|','|');
					System.out.println ("====================================================================================================================\n");


					//atualizar a variavel passou_opcao1 para true, para que as outras opcoes do menu possam ser utilizadas
					passou_opcao1 = true;
					break;
            		
            	
				//caso o usuario escolha a opcao 2 do menu, mostrar a quantidade total de cada tipo de produto numa tabela
            	case 2:
            		System.out.println ("||==========================================================||");
            		System.out.println ("||    Combustivel    ||    Alimento    ||    Medicamento    ||");
					System.out.println ("||-------------------||----------------||-------------------||");
            		System.out.printf  ("%c%c%10d%10c%c%10d%7c%c%11d%9c%c\n" ,'|','|',qC,'|','|',qA,'|','|',qM,'|','|');
            		System.out.println ("||==========================================================||\n");
            		
            		break;
            	
				//caso o usuario escolha a opcao 3 do menu, mostrar o valor total de cada tipo de produto numa tabela
            	case 3:
            		System.out.println ("||========================================================================================||");
            		System.out.println ("||         Combustivel         ||         Alimento         ||         Medicamento         ||");
					System.out.println ("||-----------------------------||--------------------------||-----------------------------||");
					System.out.printf  ("%c%c%19s%11c%c%16s%11c%c%19s%11c%c\n" ,'|','|',mt.format(vtC),'|','|',mt.format(vtA),'|','|',mt.format(vtM),'|','|');
            		System.out.println ("||========================================================================================||\n");
            		

            		break;

				//caso o usuario escolha a opcao 4 do menu, mostrar o valor total da importacao
            	case 4:
            		System.out.println ("================================");
            		System.out.println ("||  Valor total da importacao ||");
					System.out.println ("||----------------------------||");
            		System.out.printf  ("%c%c%19s%10c%c", '|' , '|' , mt.format(acum), '|' , '|');
            		System.out.println ("\n||============================||\n");
            		
            		
            		break;

				//caso o usuario escolha a opcao 5 do menu, mostrar o valor total das penalizacoes
            	case 5:
            		System.out.println ("||=========================================||");
            		System.out.println ("||      Valor total da penalizacao         ||");
					System.out.println ("||-----------------------------------------||");
            		System.out.printf  ("%c%c%27s%15c%c\n" ,'|','|',mt.format(vTP),'|','|');
            		System.out.println ("||=========================================||\n");
            		
            	    
            	
            		break;

				//caso o usuario escolha a opcao 6 do menu, mostrar qual o tipo de produto com menor valor total, ou se existem dois ou mais produtos com o mesmo valor total
            	case 6: 

				    //validar se o usuario ja passou pela opcao 1 do menu, para que possa ser utilizado a opcao 6 do menu, caso contrario mostrar uma mensagem de erro
					if(passou_opcao1 == true) 
					{

						if (vtC < vtA && vtC < vtM) 
						{
							System.out.println ("Valor do combustivel e menor");
							menorC = true;            			
						}
						else
							if (vtA < vtM && vtA < vtC) 
							{
								System.out.println ("Valor do alimento e menor");
								menorA = true;
							}
						   else
						   {
								if (vtM < vtC && vtM < vtA)
								{
									System.out.println ("Valor do medicamento e menor");
									menorM = true;
								}
								else
								{
									System.out.println ("Existem dois ou mais produtos com o mesmo valor. \nTente validar mais um cliente primeiro!");
								}
							}
					}
					else
					{
						System.out.println("Ainda nao foram introduzidos dados, por passe da opcao 1 primeiro!\n");
					}
            		
            		break;
            	
				//
            	case 7:
					if (passou_opcao1 == true)
					{
						if (acum > DESPESAS)
						{
							System.out.println ("O valor da empressa ultrapassou o orcamento!");
						    esta_dentro_do_orcamento = false;
						}
						else
						{
							System.out.println ("O valor da empresa esta dentro do orcamento!");
							esta_dentro_do_orcamento = true;
						}
					}
					else
					{
						System.out.println("Por favor passe da opcao 1 primeiro antes de ver o estado da empresa!\n");
					}
            		break;

            	case 8:
            		if(passou_opcao1 == true)
            		{
						System.out.println("=======================================================================");
						System.out.println("|| Remessas    || Quant Total ||   Valor Total   || Tem menor custo? ||");
						System.out.println("||-------------||-------------||-----------------||------------------||");
						System.out.printf ("|| Combustivel || %6d      || %15s || %10s       ||\n" ,qC,mt.format(vtC),menorC);
						System.out.printf ("|| Alimento    || %6d      || %15s || %10s       ||\n" ,qA,mt.format(vtA),menorA);
						System.out.printf ("|| Medicamento || %6d      || %15s || %10s       ||\n" ,qM,mt.format(vtM),menorM);
						System.out.println("=======================================================================\n");
            		}
            		else
            		{
            			System.out.println("Por favor passe da opcao 1 primeiro antes de ver o relatorio!\n");
            		}
            		break;
            		
				case 9:
					if(passou_opcao1 == true)
					{
						System.out.println("\n===========================================================================================");
						System.out.println("||                                RELATORIO CORPORATIVO                                  ||");
						System.out.println("===========================================================================================");
						System.out.println("|| 1. RELATORIO GERAL DA EMPRESA                                                         ||");
						System.out.println("||---------------------------------------------------------------------------------------||");
						System.out.printf ("|| Faturamento Bruto Total    | %56s ||\n", mt.format(acum));
						System.out.printf ("|| Total em Penalizacoes      | %56s ||\n", mt.format(vTP));
						System.out.printf ("|| Limite de Despesas         | %56s ||\n", mt.format(DESPESAS));
						System.out.printf ("|| Esta dentro do orcamento?  | %56s ||\n", esta_dentro_do_orcamento);
						System.out.println("||---------------------------------------------------------------------------------------||");
						System.out.println("|| 2. ESTADO DAS REMESSAS POR CATEGORIA                                                  ||");
						System.out.println("||---------------------------------------------------------------------------------------||");
						System.out.println("|| Categoria     | Transacoes |   Vol. Importado  | Faturamento Total | Custo Mais Baixo ||");
						System.out.println("||---------------|------------|-------------------|-------------------|------------------||");
						System.out.printf ("|| Combustivel   | %10d | %17s | %17s | %16s ||\n", contador_Combustivel, litros.format(qC), mt.format(vtC), menorC);
						System.out.printf ("|| Alimentos     | %10d | %17s | %17s | %16s ||\n", contador_Alimentos, toneladas.format(qA), mt.format(vtA), menorA);
						System.out.printf ("|| Medicamentos  | %10d | %17s | %17s | %16s ||\n", contador_Medicamentos, caixas.format(qM), mt.format(vtM), menorM);
						System.out.println("===========================================================================================\n");

					}
					else
					{
						System.out.println("Por favor passe da opcao 1 primeiro antes de ver o relatorio!\n");
					}
					break;
            		
            	case 10:
            		System.out.println("==============================================");
            		System.out.println("|| Nome dos programadores ||     Codigo     ||");
            		System.out.println("||------------------------||----------------||");
            		System.out.println("||     Alaine General     ||    20260665    ||");
            		System.out.println("||     Lysandro Jose      ||    20260244    ||");
            		System.out.println("||     Kleyton Velichane  ||    20250671    ||");
            		System.out.println("||     Wendy Maduela      ||    20260835    ||");
            		System.out.println("==============================================");
            		break;
            		
            		
            	case 11: System.out.println("Obrigado por usar o programa!"); break;
            		
            	
            	default : System.out.println("Opcao invalida, Tente novamente!"); break; 
            }


	    	
	    
	    
	
	    
	}while(op != 11);
  }
}

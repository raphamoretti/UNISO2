import matplotlib.pyplot as plt
import seaborn as sns

dados = [[1, 2, 3],
         [4, 5, 6],
         [7, 8, 9]]

sns.heatmap(dados, cmap='YlGnBu', annot=True, cbar=True)

plt.title('Mapa de Calor')
plt.xlabel('Eixo X')
plt.ylabel('Eixo Y')
plt.show()
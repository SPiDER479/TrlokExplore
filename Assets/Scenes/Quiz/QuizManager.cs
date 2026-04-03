using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class QuizManager : MonoBehaviour
{
    private enum quizState
    {
        Name,
        Category,
        Quiz,
        Result
    }

    private quizState currentState;
    
    [SerializeField] private QuestionsList[] categories;
    
    [SerializeField] private GameObject namePanel;
    [SerializeField] private TMP_Text nameInputField;

    [SerializeField] private GameObject categoryPanel;
    [SerializeField] private GameObject categoryButtonPrefab;

    [SerializeField] private GameObject quizPanel;
    [SerializeField] private TMP_Text questiontText;
    [SerializeField] private Button optionA;
    [SerializeField] private Button optionB;
    [SerializeField] private Button optionC;
    [SerializeField] private Button optionD;
    
    [SerializeField] private GameObject resultPanel;
    [SerializeField] private TMP_Text resultText;

    private int currentQuestion;
    private QuestionsList currentQuestions;
    private string playerName;
    private int score;
    
    private void Awake()
    {
        currentState = quizState.Name;
    }

    private void Start()
    {
        namePanel.SetActive(true);
        categoryPanel.SetActive(false);
        quizPanel.SetActive(false);
        resultPanel.SetActive(false);
    }

    private void Update()
    {
        if (currentState == quizState.Name)
        {
            if (Input.GetKeyDown(KeyCode.Alpha8))
            {
                if (nameInputField.text != "")
                {
                    playerName = nameInputField.text.Substring(0, nameInputField.text.Length - 2);
                    
                    namePanel.SetActive(false);
                    
                    currentState = quizState.Category;
                    PopulateCategories();
                    categoryPanel.SetActive(true);
                }
            }
        }
    }

    private void PopulateCategories()
    {
        foreach (QuestionsList questionsList in categories)
        {
            Button categoryButton = Instantiate(categoryButtonPrefab, categoryPanel.transform).GetComponent<Button>();
            categoryButton.transform.GetComponentInChildren<TMP_Text>().text = questionsList.name;
            categoryButton.onClick.AddListener(() => StartQuiz(questionsList));
        }
    }

    private void StartQuiz(QuestionsList questionsList)
    {
        categoryPanel.SetActive(false);
        
        currentState = quizState.Quiz;
        quizPanel.SetActive(true);
        currentQuestions = questionsList;
        
        NextQuestion(currentQuestions.questions[currentQuestion]);
    }

    private void NextQuestion(Question question)
    {
        questiontText.text = question.question;
            
        optionA.onClick.RemoveAllListeners();
        optionA.onClick.AddListener(() => CheckAnswer(0, question.correctOption));
        optionA.GetComponentInChildren<TMP_Text>().text = question.optionA;
            
        optionB.onClick.RemoveAllListeners();
        optionB.onClick.AddListener(() => CheckAnswer(1, question.correctOption));
        optionB.GetComponentInChildren<TMP_Text>().text = question.optionB;
            
        optionC.onClick.RemoveAllListeners();
        optionC.onClick.AddListener(() => CheckAnswer(2, question.correctOption));
        optionC.GetComponentInChildren<TMP_Text>().text = question.optionC;
            
        optionD.onClick.RemoveAllListeners();
        optionD.onClick.AddListener(() => CheckAnswer(3, question.correctOption));
        optionD.GetComponentInChildren<TMP_Text>().text = question.optionD;
    }

    private void CheckAnswer(int choice, int correctOption)
    {
        if (correctOption == choice) ++score;

        currentQuestion++;
        if (currentQuestion < currentQuestions.questions.Length) NextQuestion(currentQuestions.questions[currentQuestion]);
        else
        {
            quizPanel.SetActive(false);
            
            currentState = quizState.Result;
            resultPanel.SetActive(true);
            ShowResult();
        }
    }

    private void ShowResult()
    {
        resultText.text = playerName + " has scored " + score + " / " + currentQuestions.questions.Length +
                          " in the TrlokXplore Quiz in the category " + currentQuestions.name;
        
        ScreenCapture.CaptureScreenshot(playerName + "_" + currentQuestions.name + "_Result.png");
    }
}
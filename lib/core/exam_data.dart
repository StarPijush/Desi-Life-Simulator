// lib/core/exam_data.dart

class ExamQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String category; // 'Math', 'Science', 'Critical Thinking', 'Business', 'Arts'

  const ExamQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
  });
}

class ExamData {
  static const List<ExamQuestion> questionBank = [
    // ── Math & Logic ──
    ExamQuestion(
      question: "If 5 machines take 5 minutes to make 5 widgets, how long would it take 100 machines to make 100 widgets?",
      options: ["100 minutes", "5 minutes", "20 minutes", "50 minutes"],
      correctIndex: 1,
      category: "Math",
    ),
    ExamQuestion(
      question: "Solve for x: 3x + 7 = 22.",
      options: ["3", "5", "15", "6"],
      correctIndex: 1,
      category: "Math",
    ),
    ExamQuestion(
      question: "What is the square root of 144?",
      options: ["10", "11", "12", "14"],
      correctIndex: 2,
      category: "Math",
    ),
    ExamQuestion(
      question: "A bat and a ball cost ₹1.10 in total. The bat costs ₹1.00 more than the ball. How much does the ball cost?",
      options: ["₹0.10", "₹0.05", "₹0.01", "₹0.15"],
      correctIndex: 1,
      category: "Math",
    ),
    ExamQuestion(
      question: "What is the next number in the sequence: 2, 4, 8, 16, ...?",
      options: ["24", "30", "32", "64"],
      correctIndex: 2,
      category: "Math",
    ),
    ExamQuestion(
      question: "If you rotate a 3D cube, how many faces can you see at most from one fixed point?",
      options: ["2", "3", "4", "6"],
      correctIndex: 1,
      category: "Math",
    ),
    ExamQuestion(
      question: "What is 15% of 200?",
      options: ["20", "30", "35", "40"],
      correctIndex: 1,
      category: "Math",
    ),

    // ── Science (Physics/Chem/Bio) ──
    ExamQuestion(
      question: "What is the chemical symbol for Gold?",
      options: ["Ag", "Au", "Pb", "Fe"],
      correctIndex: 1,
      category: "Science",
    ),
    ExamQuestion(
      question: "Which organ in the human body is responsible for pumping blood?",
      options: ["Lungs", "Brain", "Heart", "Liver"],
      correctIndex: 2,
      category: "Science",
    ),
    ExamQuestion(
      question: "What force keeps us on the ground?",
      options: ["Magnetism", "Friction", "Gravity", "Inertia"],
      correctIndex: 2,
      category: "Science",
    ),
    ExamQuestion(
      question: "Which planet is known as the Red Planet?",
      options: ["Venus", "Mars", "Jupiter", "Saturn"],
      correctIndex: 1,
      category: "Science",
    ),
    ExamQuestion(
      question: "What is the powerhouse of the cell?",
      options: ["Nucleus", "Ribosome", "Mitochondria", "Vacuole"],
      correctIndex: 2,
      category: "Science",
    ),
    ExamQuestion(
      question: "What gas do plants absorb from the atmosphere for photosynthesis?",
      options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"],
      correctIndex: 2,
      category: "Science",
    ),
    ExamQuestion(
      question: "Which Newton's law states 'For every action, there is an equal and opposite reaction'?",
      options: ["First Law", "Second Law", "Third Law", "Fourth Law"],
      correctIndex: 2,
      category: "Science",
    ),

    // ── Business & Economics ──
    ExamQuestion(
      question: "What does GDP stand for?",
      options: ["Gross Domestic Price", "General Domestic Product", "Gross Domestic Product", "Global Deposit Price"],
      correctIndex: 2,
      category: "Business",
    ),
    ExamQuestion(
      question: "Which institution regulates the monetary policy in India?",
      options: ["SEBI", "RBI", "SBI", "NITI Aayog"],
      correctIndex: 1,
      category: "Business",
    ),
    ExamQuestion(
      question: "What is the term for a market with only one seller?",
      options: ["Monopoly", "Oligopoly", "Perfect Competition", "Monopsony"],
      correctIndex: 0,
      category: "Business",
    ),
    ExamQuestion(
      question: "What is 'Inflation'?",
      options: ["Decrease in prices", "Increase in purchasing power", "General increase in prices", "Stagnation of economy"],
      correctIndex: 2,
      category: "Business",
    ),
    ExamQuestion(
      question: "Which of these is a direct tax?",
      options: ["GST", "Income Tax", "Excise Duty", "Customs Duty"],
      correctIndex: 1,
      category: "Business",
    ),

    // ── Arts & Humanities ──
    ExamQuestion(
      question: "Who painted the 'Mona Lisa'?",
      options: ["Picasso", "Van Gogh", "Leonardo da Vinci", "Michelangelo"],
      correctIndex: 2,
      category: "Arts",
    ),
    ExamQuestion(
      question: "Which city is known as the 'Pink City' of India?",
      options: ["Udaipur", "Jodhpur", "Jaipur", "Bhopal"],
      correctIndex: 2,
      category: "Arts",
    ),
    ExamQuestion(
      question: "Who wrote 'Gitanjali'?",
      options: ["Premchand", "Rabindranath Tagore", "Vikram Seth", "R.K. Narayan"],
      correctIndex: 1,
      category: "Arts",
    ),
    ExamQuestion(
      question: "What is the classical dance form of Kerala?",
      options: ["Kathak", "Kathakali", "Bharatanatyam", "Kuchipudi"],
      correctIndex: 1,
      category: "Arts",
    ),
    ExamQuestion(
      question: "In which year did India gain independence?",
      options: ["1942", "1945", "1947", "1950"],
      correctIndex: 2,
      category: "Arts",
    ),

    // ── General Knowledge & Critical Thinking ──
    ExamQuestion(
      question: "If you are running a race and you pass the person in second place, what place are you in?",
      options: ["First", "Second", "Third", "Last"],
      correctIndex: 1,
      category: "Critical Thinking",
    ),
    ExamQuestion(
      question: "What comes once in a minute, twice in a moment, but never in a thousand years?",
      options: ["The letter M", "A heartbeat", "Silence", "A second"],
      correctIndex: 0,
      category: "Critical Thinking",
    ),
    ExamQuestion(
      question: "Which is the tallest mountain in the world?",
      options: ["K2", "Mount Everest", "Kanchenjunga", "Lhotse"],
      correctIndex: 1,
      category: "General",
    ),
    ExamQuestion(
      question: "Which ocean is the largest on Earth?",
      options: ["Atlantic", "Indian", "Arctic", "Pacific"],
      correctIndex: 3,
      category: "General",
    ),
    ExamQuestion(
      question: "What is the primary currency of the USA?",
      options: ["Euro", "Dollar", "Pound", "Yen"],
      correctIndex: 1,
      category: "General",
    ),
    ExamQuestion(
      question: "Capital of India is?",
      options: ["Mumbai", "Kolkata", "Chennai", "New Delhi"],
      correctIndex: 3,
      category: "General",
    ),

    // ── More Science/Tech ──
    ExamQuestion(
      question: "What is the most abundant gas in Earth's atmosphere?",
      options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Argon"],
      correctIndex: 1,
      category: "Science",
    ),
    ExamQuestion(
      question: "What does 'HTTP' stand for?",
      options: ["High Text Transfer Protocol", "Hyper Transfer Text Protocol", "Hypertext Transfer Protocol", "Hypertext Type Protocol"],
      correctIndex: 2,
      category: "Science",
    ),
    ExamQuestion(
      question: "Who is known as the father of Indian Space Program?",
      options: ["Homi Bhabha", "Vikram Sarabhai", "A.P.J. Abdul Kalam", "C.V. Raman"],
      correctIndex: 1,
      category: "Science",
    ),
    ExamQuestion(
      question: "Which element has the highest thermal conductivity?",
      options: ["Copper", "Silver", "Gold", "Aluminum"],
      correctIndex: 1,
      category: "Science",
    ),

    // ── More Math ──
    ExamQuestion(
      question: "Sum of angles in a triangle is?",
      options: ["90°", "180°", "270°", "360°"],
      correctIndex: 1,
      category: "Math",
    ),
    ExamQuestion(
      question: "What is 7 multiplied by 8?",
      options: ["54", "56", "64", "48"],
      correctIndex: 1,
      category: "Math",
    ),
    ExamQuestion(
      question: "A prime number has how many factors?",
      options: ["1", "2", "3", "Many"],
      correctIndex: 1,
      category: "Math",
    ),

    // ── More Humanities ──
    ExamQuestion(
      question: "Which river is known as the 'Sorrow of Bihar'?",
      options: ["Ganga", "Yamuna", "Kosi", "Brahmaputra"],
      correctIndex: 2,
      category: "Arts",
    ),
    ExamQuestion(
      question: "Who was the first woman Prime Minister of India?",
      options: ["Pratibha Patil", "Indira Gandhi", "Sushma Swaraj", "Sarojini Naidu"],
      correctIndex: 1,
      category: "Arts",
    ),
    ExamQuestion(
      question: "Which of these is a Rabi crop?",
      options: ["Rice", "Maize", "Wheat", "Cotton"],
      correctIndex: 2,
      category: "Arts",
    ),
  ];
}

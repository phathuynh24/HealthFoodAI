import json
import google.generativeai as genai
from config import GEMINI_API_KEY

# Configure API key for Gemini
genai.configure(api_key=GEMINI_API_KEY)

def generate_analysis_data(nutrition_data, blood_pressure, blood_sugar):
    """
    Phân tích dữ liệu dinh dưỡng và sức khỏe của người dùng, trả về các key để đưa vào prompt.
    """
    analysis_data = {}

    # Kiểm tra và ép kiểu dữ liệu cho huyết áp (systolic, diastolic)
    if isinstance(blood_pressure, str):
        try:
            blood_pressure = json.loads(blood_pressure)  # Phân tích chuỗi JSON thành dict
        except json.JSONDecodeError:
            print("Dữ liệu huyết áp không hợp lệ, không thể phân tích chuỗi JSON.")
            print("Dữ liệu huyết áp:", blood_pressure)
            return {}
        
    systolic = blood_pressure.get('systolic', 0) 
    diastolic = blood_pressure.get('diastolic', 0)

    # Kiểm tra và ép kiểu dữ liệu cho đường huyết (blood_sugar)
    try:
        blood_sugar = float(blood_sugar) if blood_sugar is not None else 0
    except ValueError:
        blood_sugar = 0  # Nếu không phải kiểu số, gán mặc định là 0

    # Kiểm tra và ép kiểu dữ liệu cho các thành phần dinh dưỡng (cholesterol, sodium, sugars, carbohydrate)
    cholesterol = float(nutrition_data.get('cholesterol', 0) or 0)
    sodium = float(nutrition_data.get('sodium', 0) or 0)
    sugars = float(nutrition_data.get('sugars', 0) or 0)
    total_carbohydrate = float(nutrition_data.get('total_carbohydrate', 0) or 0)

    # Phân loại tình trạng huyết áp và đường huyết
    critical_blood_pressure = systolic > 180 or diastolic > 120
    high_blood_pressure = systolic > 140 or diastolic > 90
    critical_blood_sugar = blood_sugar > 200
    high_blood_sugar = blood_sugar > 180

    # Cảnh báo tình trạng huyết áp và đường huyết
    analysis_data['blood_pressure_status'] = 'Critical' if critical_blood_pressure else 'High' if high_blood_pressure else 'Normal'
    analysis_data['blood_sugar_status'] = 'Critical' if critical_blood_sugar else 'High' if high_blood_sugar else 'Normal'

    # Thêm chỉ số huyết áp và đường huyết vào phân tích
    analysis_data['blood_pressure_values'] = f"Systolic: {systolic}, Diastolic: {diastolic}"
    analysis_data['blood_sugar_value'] = f"{blood_sugar} mg/dL"

    # Kiểm tra thành phần dinh dưỡng của món ăn
    analysis_data['cholesterol_warning'] = cholesterol > 100
    analysis_data['sodium_warning'] = sodium > 750
    analysis_data['sugar_warning'] = sugars > 20
    analysis_data['carbohydrate_warning'] = total_carbohydrate > 90

    # Thêm các giá trị cụ thể của dinh dưỡng
    analysis_data['nutrition_details'] = {
        'cholesterol': cholesterol,
        'sodium': sodium,
        'sugars': sugars,
        'carbohydrate': total_carbohydrate
    }

    return analysis_data

# Cảnh báo sức khỏe từ Gemini API
def get_gemini_warning(analysis_data, model_name="gemini-1.5-flash"):
    """
    Gọi Gemini API để lấy cảnh báo sức khỏe và dinh dưỡng từ phân tích dữ liệu món ăn.
    
    Parameters:
    - analysis_data: Dictionary chứa thông tin về tình trạng huyết áp, đường huyết và dinh dưỡng
    - model_name: Tên model Gemini để sử dụng cho dự đoán (mặc định là "gemini-1.5-pro")
    
    Returns:
    - Warning message từ Gemini API hoặc lỗi nếu không thành công.
    """
    # Tạo prompt cho Gemini dựa trên phân tích dữ liệu
    prompt = f"""
    Bạn là một chuyên gia dinh dưỡng và sức khỏe. Dưới đây là tình trạng sức khỏe người dùng, họ chuẩn bị ăn 1 món ăn mới. Hãy đưa ra cảnh báo cho họ dựa trên thông tin sau:

    - Tình trạng huyết áp: {analysis_data['blood_pressure_status']}
    - Tình trạng đường huyết: {analysis_data['blood_sugar_status']}
    - Giá trị huyết áp: {analysis_data['blood_pressure_values']}
    - Giá trị đường huyết: {analysis_data['blood_sugar_value']}

    Thông tin dinh dưỡng của món ăn:
    - Cholesterol: {'Cao' if analysis_data['cholesterol_warning'] else 'Bình thường'}
    - Sodium: {'Cao' if analysis_data['sodium_warning'] else 'Bình thường'}
    - Đường: {'Cao' if analysis_data['sugar_warning'] else 'Bình thường'}
    - Carbohydrate: {'Cao' if analysis_data['carbohydrate_warning'] else 'Bình thường'}
    Dựa trên phân tích, hãy đưa ra cảnh báo ngắn cho người dùng có nên ăn món ăn này hay không.
    
    Bạn tham khảo ví dụ này để viết cảnh báo ngắn này: 
        - Mặc dù huyết áp của bạn bình thường (130/80), nhưng đường huyết của bạn (170 mg/dL) cao hơn mức bình thường.
        - Món ăn này có lượng cholesterol và sodium cao, không tốt cho tim mạch và huyết áp.
    """

    try:
        # Gọi API Gemini để lấy cảnh báo sức khỏe
        model = genai.GenerativeModel(model_name)
        response = model.generate_content([prompt])

        # Trả về kết quả từ Gemini
        return [response.text.strip()]  # Lấy ra văn bản cảnh báo từ Gemini API

    except Exception as e:
        # Xử lý lỗi trong quá trình gọi API Gemini
        print(f"Error while calling Gemini API: {str(e)}")
        return "Lỗi khi gọi API Gemini. Vui lòng thử lại sau."

# Cảnh báo sức khoẻ khi không có blood_pressure và blood_sugar, dùng if-else để kiểm tra
def get_normal_warning(nutrition_data):
    # Kiểm tra và ép kiểu dữ liệu cho các thành phần dinh dưỡng (cholesterol, sodium, sugars, carbohydrate)
    cholesterol = float(nutrition_data.get('cholesterol', 0) or 0)
    sodium = float(nutrition_data.get('sodium', 0) or 0)
    sugars = float(nutrition_data.get('sugars', 0) or 0)
    total_carbohydrate = float(nutrition_data.get('total_carbohydrate', 0) or 0)

    analysic_data = {}
    # Kiểm tra thành phần dinh dưỡng của món ăn
    analysic_data['cholesterol_warning'] = cholesterol > 100  # Điều chỉnh từ 30 mg lên 100 mg
    analysic_data['sodium_warning'] = sodium > 750           # Điều chỉnh từ 300 mg lên 750 mg
    analysic_data['sugar_warning'] = sugars > 20             # Điều chỉnh từ 15 g lên 20 g
    analysic_data['carbohydrate_warning'] = total_carbohydrate > 90  # Điều chỉnh từ 50 g lên 90 g

    warnings = []
    if analysic_data['cholesterol_warning']:
        warnings.append("Cảnh báo: Món ăn này có thể chứa quá nhiều cholesterol.")
    if analysic_data['sodium_warning']:
        warnings.append("Cảnh báo: Món ăn này có thể chứa quá nhiều muối, không tốt cho huyết áp.")
    if analysic_data['sugar_warning']:
        warnings.append("Cảnh báo: Món ăn này có thể chứa quá nhiều đường, không tốt cho huyết áp.")
    if analysic_data['carbohydrate_warning']:
        warnings.append("Cảnh báo: Món ăn này có thể chứa quá nhiều carbohydrate, không tốt cho huyết áp.")
    return warnings
    